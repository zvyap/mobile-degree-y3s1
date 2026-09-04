import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_renting_app/bike_station/shared_map.dart';

/// Base abstraction for station map views.
///
/// Encapsulates common state, Supabase/local station data loading,
/// GPS location resolution, distance computation/formatting, geofencing,
/// and map presentation.
///
/// Can be extended by:
/// - [RefinedUserBikeView] for the main station browsing & admin screen.
/// - [_ReturnStationMap] for the return station selection map in renting.
abstract class BaseStationMapView extends StatefulWidget {
  final List<Map<String, dynamic>>? initialStations;
  final LatLng? initialCenter;
  final double initialZoom;
  final String? selectedStationId;
  final LatLng? riderLocation;
  final double? geofenceRadiusMeters;
  final List<LatLng>? routePoints;
  final bool isEmbedded;
  final double? height;
  final bool showHeader;
  final bool showRecenterButton;
  final ValueChanged<String>? onStationTap;
  final ValueChanged<LatLng>? onMapLongPress;
  final bool isAdminMode;

  const BaseStationMapView({
    super.key,
    this.initialStations,
    this.initialCenter,
    this.initialZoom = 14.0,
    this.selectedStationId,
    this.riderLocation,
    this.geofenceRadiusMeters,
    this.routePoints,
    this.isEmbedded = false,
    this.height,
    this.showHeader = true,
    this.showRecenterButton = true,
    this.onStationTap,
    this.onMapLongPress,
    this.isAdminMode = false,
  });
}

abstract class BaseStationMapViewState<T extends BaseStationMapView> extends State<T> {
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
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    initStationData();

    searchFocusNode.addListener(_handleSearchFocus);
  }

  void _handleSearchFocus() {
    if (mounted) {
      setState(() {
        isSearching = searchFocusNode.hasFocus || searchController.text.trim().isNotEmpty;
      });
    }
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialStations != oldWidget.initialStations && widget.initialStations != null) {
      setState(() {
        stations = List<Map<String, dynamic>>.from(widget.initialStations!);
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
  }

  @override
  void dispose() {
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
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      debugPrint("Location retrieval error: $e");
      return null;
    }
  }

  /// Initialize station data either from [widget.initialStations] or Supabase
  Future<void> initStationData() async {
    if (widget.initialStations != null) {
      setState(() {
        stations = List<Map<String, dynamic>>.from(widget.initialStations!);
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

  /// Fetch stations from Supabase and sort them by distance from user location
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
          SnackBar(content: Text('Error loading stations: $e')),
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

  /// Recenter GPS position and update stations
  Future<void> recenterToGps() async {
    final pos = await getUserLocation();
    if (pos != null && mounted) {
      setState(() => userLocation = pos);
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
      stations: stations,
      riderLocation: widget.riderLocation ?? userLocation,
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
}
