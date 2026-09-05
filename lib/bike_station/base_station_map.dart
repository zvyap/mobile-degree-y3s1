import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_renting_app/bike_station/osrm_service.dart';
import 'package:bike_renting_app/bike_station/shared_map.dart';
import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:bike_renting_app/l10n/l10n.dart';

export 'package:bike_renting_app/bike_station/osrm_service.dart';
export 'package:bike_renting_app/bike_station/shared_map.dart' show GoogleMapsLocationMarker;

/// Base abstraction for station map views.
abstract class BaseStationMapView extends StatefulWidget {
  final List<Map<String, dynamic>>? initialStations;
  final LatLng? initialCenter;
  final double initialZoom;
  final String? selectedStationId;
  final LatLng? riderLocation;
  final double? riderHeading;
  final double? geofenceRadiusMeters;
  final List<LatLng>? routePoints;
  final bool isEmbedded;
  final double? height;
  final bool showHeader;
  final bool showRecenterButton;
  final ValueChanged<String>? onStationTap;
  final ValueChanged<LatLng>? onMapLongPress;
  final bool isAdminMode;
  final bool trackLiveLocation;
  final bool showDirectionIndicator;

  const BaseStationMapView({
    super.key,
    this.initialStations,
    this.initialCenter,
    this.initialZoom = 14.0,
    this.selectedStationId,
    this.riderLocation,
    this.riderHeading,
    this.geofenceRadiusMeters,
    this.routePoints,
    this.isEmbedded = false,
    this.height,
    this.showHeader = true,
    this.showRecenterButton = true,
    this.onStationTap,
    this.onMapLongPress,
    this.isAdminMode = false,
    this.trackLiveLocation = true,
    this.showDirectionIndicator = true,
  });
}

abstract class BaseStationMapViewState<T extends BaseStationMapView> extends State<T> {
  // Shared key to command the map controller from the base state
  final GlobalKey<SharedBikeMapState> mapTileKey = GlobalKey<SharedBikeMapState>();

  SupabaseClient? get supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();

  Map<String, dynamic>? selectedStation;
  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> filteredStations = [];
  LatLng? userLocation;
  double? userHeading;
  StreamSubscription<Position>? _positionSubscription;
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    initStationData();
    if (widget.trackLiveLocation) {
      _startPositionStream();
    }
    searchFocusNode.addListener(_handleSearchFocus);
  }

  void _handleSearchFocus() {
    if (mounted) {
      setState(() {
        isSearching = searchFocusNode.hasFocus || searchController.text.trim().isNotEmpty;
      });
    }
  }

  Future<void> _startPositionStream() async {
    if (!widget.trackLiveLocation) return;
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      _positionSubscription?.cancel();
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      );
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
            (Position position) {
          if (!mounted) return;
          final newPos = LatLng(position.latitude, position.longitude);
          double? heading = position.heading;
          if (heading == 0.0 && userLocation != null) {
            final calcBearing = Geolocator.bearingBetween(
              userLocation!.latitude,
              userLocation!.longitude,
              newPos.latitude,
              newPos.longitude,
            );
            if (calcBearing != 0.0) {
              heading = calcBearing;
            }
          }
          setState(() {
            userLocation = newPos;
            if (heading != 0.0) {
              userHeading = heading;
            }
          });
        },
        onError: (err) {
          debugPrint("Live location stream error: $err");
        },
      );
    } catch (e) {
      debugPrint("Could not start live location stream: $e");
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStations != oldWidget.initialStations && widget.initialStations != null) {
      var list = List<Map<String, dynamic>>.from(widget.initialStations!);
      if (!widget.isAdminMode) {
        list.removeWhere((s) => s['status']?.toString().trim().toLowerCase() == 'terminated');
      }
      setState(() {
        stations = list;
        filteredStations = stations;
        if (widget.selectedStationId != null) {
          selectedStation = stations
              .where((s) => s['id']?.toString() == widget.selectedStationId)
              .firstOrNull;
        }
      });
    } else if (widget.selectedStationId != oldWidget.selectedStationId) {
      setState(() {
        selectedStation = widget.selectedStationId != null
            ? stations
            .where((s) => s['id']?.toString() == widget.selectedStationId)
            .firstOrNull
            : null;
      });
    }
    if (widget.trackLiveLocation != oldWidget.trackLiveLocation) {
      if (widget.trackLiveLocation) {
        _startPositionStream();
      } else {
        _positionSubscription?.cancel();
        _positionSubscription = null;
      }
    }
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  static double? toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  /// Request GPS permission and fetch user location
  Future<LatLng?> getUserLocation() async {
    if (widget.riderLocation != null) {
      return widget.riderLocation;
    }
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return userLocation;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return userLocation;
      }
      if (permission == LocationPermission.deniedForever) return userLocation;

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 4),
          ),
        );
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }
      position ??= await Geolocator.getLastKnownPosition();

      final resolvedPosition = position;
      if (resolvedPosition != null) {
        if (resolvedPosition.heading != 0.0) {
          userHeading = resolvedPosition.heading;
        }
        return LatLng(resolvedPosition.latitude, resolvedPosition.longitude);
      }
      return userLocation;
    } catch (e) {
      debugPrint("Location retrieval error: $e");
      return userLocation;
    }
  }

  /// Initialize station data either from [widget.initialStations] or Supabase
  Future<void> initStationData() async {
    if (widget.initialStations != null) {
      var list = List<Map<String, dynamic>>.from(widget.initialStations!);
      if (!widget.isAdminMode) {
        list.removeWhere((s) => s['status']?.toString().trim().toLowerCase() == 'terminated');
      }
      setState(() {
        stations = list;
        filteredStations = stations;
        isLoading = false;
        if (widget.selectedStationId != null) {
          selectedStation = stations
              .where((s) => s['id']?.toString() == widget.selectedStationId)
              .firstOrNull;
        }
      });
      final pos = widget.riderLocation ?? await getUserLocation();
      if (mounted && pos != null) {
        setState(() => userLocation = pos);
      }
    } else {
      await fetchStations();
    }
  }

  /// Fetch stations from Supabase and filter out Terminated ones for non-admin mode
  Future<void> fetchStations() async {
    setState(() => isLoading = true);
    try {
      final userPos = await getUserLocation();
      if (mounted) setState(() => userLocation = userPos);

      final client = supabase;
      if (client == null) {
        if (mounted) setState(() => isLoading = false);
        return;
      }

      final response = await client
          .from('stations')
          .select()
          .eq('is_active', true);

      List<Map<String, dynamic>> fetched = List<Map<String, dynamic>>.from(response);

      // Exclude Terminated stations in User View
      if (!widget.isAdminMode) {
        fetched.removeWhere((s) => s['status']?.toString().trim().toLowerCase() == 'terminated');
      }

      if (userPos != null) {
        for (var s in fetched) {
          final double? lat = toDouble(s['latitude'] ?? s['lat']);
          final double? lng = toDouble(s['longitude'] ?? s['lng']);
          if (lat != null && lng != null) {
            s['distance_meters'] = Geolocator.distanceBetween(
              userPos.latitude,
              userPos.longitude,
              lat,
              lng,
            );
          }
        }

        fetched.sort((a, b) {
          final aDist = (a['distance_meters'] as num?) ?? double.infinity;
          final bDist = (b['distance_meters'] as num?) ?? double.infinity;
          return aDist.compareTo(bDist);
        });
      }

      if (mounted) {
        setState(() {
          stations = fetched;
          filteredStations = fetched;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorLoadingStations(e.toString()))),
        );
      }
    }
  }

  void filterStations(String query) {
    final trimmed = query.trim().toLowerCase();
    setState(() {
      if (trimmed.isEmpty) {
        filteredStations = stations;
      } else {
        filteredStations = stations.where((s) {
          final name = (s['name'] ?? '').toString().toLowerCase();
          final address = (s['address'] ?? '').toString().toLowerCase();
          return name.contains(trimmed) || address.contains(trimmed);
        }).toList();
      }
      isSearching = true;
    });
  }

  String formatDistance(dynamic distanceMeters) {
    if (distanceMeters == null) return '';
    final double meters = (distanceMeters as num).toDouble();
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  /// Recenter GPS position, move map camera, and update stations
  Future<void> recenterToGps() async {
    final immediatePos = widget.riderLocation ?? userLocation;
    if (immediatePos != null && mounted) {
      mapTileKey.currentState?.moveCameraToLocation(immediatePos);
    }

    final pos = await getUserLocation() ?? immediatePos ?? widget.initialCenter;
    if (pos != null && mounted) {
      setState(() => userLocation = pos);
      mapTileKey.currentState?.moveCameraToLocation(pos);
    }
    if (widget.initialStations == null) {
      await fetchStations();
    }
  }

  void handleStationTap(String stationId) {
    if (widget.onStationTap != null) {
      widget.onStationTap!(stationId);
    } else {
      final station = stations
          .where((s) => s['id']?.toString() == stationId)
          .firstOrNull;
      if (station != null && mounted) {
        setState(() => selectedStation = station);
      }
    }
  }

  /// Builds the underlying map widget layer
  Widget buildMapLayer(BuildContext context) {
    return SharedBikeMap(
      key: mapTileKey,
      stations: stations,
      riderLocation: widget.riderLocation ?? userLocation,
      riderHeading: widget.riderHeading ?? userHeading,
      showDirectionIndicator: widget.showDirectionIndicator,
      trackLiveLocation: widget.trackLiveLocation,
      selectedStationId: widget.selectedStationId ?? selectedStation?['id']?.toString(),
      isAdminMode: widget.isAdminMode,
      geofenceRadiusMeters: widget.geofenceRadiusMeters,
      routePoints: widget.routePoints,
      initialCenter: widget.initialCenter,
      initialZoom: widget.initialZoom,
      onStationTap: handleStationTap,
      onMapLongPress: widget.onMapLongPress,
    );
  }

  /// Builds the recenter GPS button
  Widget buildRecenterButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(Icons.my_location, color: colorScheme.onSurface),
        onPressed: recenterToGps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEmbedded) {
      return buildEmbeddedView(context);
    }
    return buildFullScreenView(context);
  }

  /// Default layout when used as an embedded widget
  Widget buildEmbeddedView(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: widget.height ?? 200,
      child: Stack(
        children: [
          Positioned.fill(child: buildMapLayer(context)),
          if (widget.showRecenterButton)
            Positioned(
              right: 12,
              bottom: 12,
              child: buildRecenterButton(context),
            ),
        ],
      ),
    );
  }

  /// Subclasses should override this or implement full screen UI
  Widget buildFullScreenView(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: buildMapLayer(context),
    );
  }

  /// Builds placeholder / selected station row display
  Widget buildStationPlaceholderRow({
    required Map<String, dynamic>? station,
    required bool isOrigin,
    required VoidCallback onEdit,
    String? defaultTitle,
    String? defaultSubtitle,
  }) {
    return StationPlaceholderRow(
      station: station,
      isOrigin: isOrigin,
      onEdit: onEdit,
      defaultTitle: defaultTitle,
      defaultSubtitle: defaultSubtitle,
    );
  }

  /// Builds route calculation status, ETA, and distance display
  Widget buildRouteDisplay({
    required bool isCalculating,
    bool isRouteTooFar = false,
    OsrmRouteResult? routeResult,
  }) {
    return StationRouteDisplay(
      isCalculating: isCalculating,
      isRouteTooFar: isRouteTooFar,
      routeResult: routeResult,
    );
  }
}

/// Displays a station row or a placeholder (e.g. "Station A" / "Station B")
/// with an edit button.
class StationPlaceholderRow extends StatelessWidget {
  final Map<String, dynamic>? station;
  final bool isOrigin;
  final VoidCallback? onEdit;
  final bool showEdit;
  final String? defaultTitle;
  final String? defaultSubtitle;

  const StationPlaceholderRow({
    super.key,
    required this.station,
    required this.isOrigin,
    this.onEdit,
    this.showEdit = true,
    this.defaultTitle,
    this.defaultSubtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMaintenance = station?['status']?.toString().trim().toLowerCase() == 'under maintenance';
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    final String resolvedTitle = defaultTitle ?? (isOrigin ? (l10n?.stationA ?? 'Station A') : (l10n?.stationB ?? 'Station B'));
    final String resolvedSubtitle = defaultSubtitle ?? (isOrigin ? (l10n?.selectOriginStation ?? 'Select origin station') : (l10n?.selectDestinationStation ?? 'Select destination station'));

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isMaintenance ? const Color(0xFFF97316).withValues(alpha: 0.1) : null,
            border: Border.all(
              color: isMaintenance ? const Color(0xFFF97316) : colorScheme.onSurface,
              width: 2,
            ),
          ),
          child: Icon(
            isMaintenance ? Icons.build_rounded : Icons.location_on,
            size: 20,
            color: isMaintenance ? const Color(0xFFF97316) : colorScheme.onSurface,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      station?['name'] ?? resolvedTitle,
                      style: TextStyle(
                        color: station != null ? colorScheme.onSurface : colorScheme.onSurface.withValues(alpha: 0.6),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isMaintenance) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFF97316), width: 1),
                      ),
                      child: Text(
                        l10n?.underMaintenance ?? 'Under Maintenance',
                        style: const TextStyle(
                          color: Color(0xFFF97316),
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                station?['address'] ?? resolvedSubtitle,
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (showEdit && onEdit != null)
          IconButton(
            icon: Icon(Icons.edit_square, color: colorScheme.onSurface.withValues(alpha: 0.7)),
            onPressed: onEdit,
          ),
      ],
    );
  }
}

/// Displays route calculation status, errors (e.g. route too far),
/// ETA time range, duration, and total distance.
class StationRouteDisplay extends StatelessWidget {
  final bool isCalculating;
  final bool isRouteTooFar;
  final OsrmRouteResult? routeResult;

  const StationRouteDisplay({
    super.key,
    required this.isCalculating,
    this.isRouteTooFar = false,
    this.routeResult,
  });

  // Enforce UTC+8 (Malaysia Time - MYT)
  static String formatEtaRange(int durationMinutes) {
    final nowMyt = DateTime.now().toUtc().add(const Duration(hours: 8));
    final arrivalMyt = nowMyt.add(Duration(minutes: durationMinutes));
    final timeFormat = DateFormat('h:mm');
    final amPmFormat = DateFormat('a');
    return "${timeFormat.format(nowMyt)} - ${timeFormat.format(arrivalMyt)} ${amPmFormat.format(arrivalMyt)}";
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = Localizations.of<AppLocalizations>(context, AppLocalizations);

    if (isCalculating) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    if (isRouteTooFar) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.selectedStationTooFar ?? 'Selected Station are too far away',
            style: const TextStyle(
              color: Color(0xFFDC2626),
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          if (routeResult != null) ...[
            const SizedBox(height: 6),
            Text(
              l10n?.totalDistanceKm(routeResult!.distanceKm.toStringAsFixed(2)) ??
                  'Total Distance: ${routeResult!.distanceKm.toStringAsFixed(2)} km',
              style: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ],
      );
    }

    if (routeResult != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n?.estimatedArrivalTime ?? 'Estimated Arrival Time (ETA)',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            formatEtaRange(routeResult!.durationMinutes),
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            l10n?.durationInMinutes(routeResult!.durationMinutes) ??
                '${routeResult!.durationMinutes} minutes',
            style: TextStyle(
              color: colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n?.totalDistanceKm(routeResult!.distanceKm.toStringAsFixed(2)) ??
                'Total Distance: ${routeResult!.distanceKm.toStringAsFixed(2)} km',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      );
    }

    return Text(
      l10n?.selectStationsToCalculateRoutePrompt ??
          'Select Station A & Station B to calculate route.',
      style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
    );
  }
}

typedef StationPlaceholderDisplay = StationPlaceholderRow;
typedef RouteInfoDisplay = StationRouteDisplay;
typedef StationRouteInfoDisplay = StationRouteDisplay;