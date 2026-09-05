import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bike_renting_app/bike_station/station_details.dart';
import 'package:bike_renting_app/l10n/l10n.dart';

// ============================================================================
// 1. MAIN PARENT SCREEN: AdminStationMapScreen
// ============================================================================
class AdminStationMapScreen extends StatefulWidget {
  const AdminStationMapScreen({super.key});

  @override
  State<AdminStationMapScreen> createState() => _AdminStationMapScreenState();
}

class _AdminStationMapScreenState extends State<AdminStationMapScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final GlobalKey<SharedBikeMapState> _mapTileKey = GlobalKey<SharedBikeMapState>();

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, dynamic>> stations = [];
  List<Map<String, dynamic>> filteredStations = [];
  bool isLoading = true;
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    _fetchStations();

    _searchFocusNode.addListener(() {
      if (mounted) {
        setState(() {
          isSearching = _searchFocusNode.hasFocus || _searchController.text.trim().isNotEmpty;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  Future<void> _fetchStations() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('stations')
          .select()
          .eq('is_active', true)
          .order('id', ascending: true);

      final fetched = List<Map<String, dynamic>>.from(response);

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
          SnackBar(content: Text(context.l10n.failedToLoadStations(e.toString()))),
        );
      }
    }
  }

  void _filterStations(String query) {
    final trimmed = query.trim().toLowerCase();
    setState(() {
      if (trimmed.isEmpty) {
        filteredStations = stations;
      } else {
        filteredStations = stations.where((s) {
          final name = (s['name'] ?? '').toString().toLowerCase();
          final address = (s['address'] ?? '').toString().toLowerCase();
          final code = (s['code'] ?? '').toString().toLowerCase();
          return name.contains(trimmed) || address.contains(trimmed) || code.contains(trimmed);
        }).toList();
      }
      isSearching = true;
    });
  }

  void _openAdminEditStation(Map<String, dynamic> station) async {
    _searchFocusNode.unfocus();
    setState(() => isSearching = false);

    final double? lat = _toDouble(station['latitude'] ?? station['lat']);
    final double? lng = _toDouble(station['longitude'] ?? station['lng']);
    if (lat != null && lng != null) {
      _mapTileKey.currentState?.moveCameraToLocation(LatLng(lat, lng));
    }

    final isSaved = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StationDetailScreen(
          stationData: station,
          isViewOnly: false,
        ),
      ),
    );

    if (isSaved == true) {
      _fetchStations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () {
          _searchFocusNode.unfocus();
          setState(() => isSearching = false);
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: SharedBikeMap(
                key: _mapTileKey,
                stations: stations,
                isAdminMode: true,
                onMapLongPress: (LatLng point) async {
                  final isSaved = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StationDetailScreen(
                        initialLat: point.latitude,
                        initialLng: point.longitude,
                        isViewOnly: false,
                      ),
                    ),
                  );

                  if (isSaved == true) {
                    _fetchStations();
                  }
                },
                onStationTap: (stationId) {
                  final selectedStation = stations.firstWhere(
                        (s) => s['id'].toString() == stationId,
                    orElse: () => {},
                  );
                  if (selectedStation.isNotEmpty) {
                    _openAdminEditStation(selectedStation);
                  }
                },
              ),
            ),

            Positioned(
              top: 50.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onChanged: _filterStations,
                      style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: context.l10n.searchStationHint,
                        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5), fontSize: 13),
                        prefixIcon: Icon(Icons.search, color: colorScheme.primary, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: Icon(Icons.clear, color: colorScheme.onSurface.withValues(alpha: 0.5), size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filterStations('');
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.touch_app, color: colorScheme.primary, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          context.l10n.longPressMapToAddStation,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (isSearching && _searchController.text.trim().isNotEmpty)
              Positioned(
                top: 106.0,
                left: 16.0,
                right: 16.0,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 12, offset: Offset(0, 6))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: filteredStations.isEmpty
                        ? Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        context.l10n.noMatchingStationsFound,
                        style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    )
                        : ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: filteredStations.length,
                      separatorBuilder: (context, index) => Divider(color: colorScheme.outline.withValues(alpha: 0.2), height: 1),
                      itemBuilder: (context, index) {
                        final station = filteredStations[index];
                        final String status = station['status']?.toString() ?? 'Normal';
                        final String code = station['code']?.toString() ?? '';

                        Color statusColor = const Color(0xFF10B981);
                        if (status == 'Under Maintenance') {
                          statusColor = const Color(0xFFF97316);
                        } else if (status == 'Terminated') {
                          statusColor = const Color(0xFFDC2626);
                        }

                        return ListTile(
                          leading: Icon(Icons.edit_location_alt, color: statusColor),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  station['name'] ?? context.l10n.unnamedStation,
                                  style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (code.isNotEmpty) ...[
                                const SizedBox(width: 8),
                                Text(
                                  code,
                                  style: TextStyle(color: colorScheme.primary, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(
                            station['address'] ?? context.l10n.noAddress,
                            style: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: statusColor, width: 1),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          onTap: () => _openAdminEditStation(station),
                        );
                      },
                    ),
                  ),
                ),
              ),

            Positioned(
              right: 16.0,
              bottom: 30.0,
              child: FloatingActionButton(
                backgroundColor: colorScheme.surfaceContainerHighest,
                onPressed: () {
                  _fetchStations();
                  _mapTileKey.currentState?.recenterToGps();
                },
                child: isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(Icons.my_location, color: colorScheme.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// 2. MAP COMPONENT: SharedBikeMap
// ============================================================================
class SharedBikeMap extends StatefulWidget {
  final List<Map<String, dynamic>> stations;
  final bool isAdminMode;
  final Function(String stationId)? onStationTap;
  final Function(LatLng coordinates)? onMapLongPress;
  final LatLng? initialCenter;
  final double initialZoom;
  final String? selectedStationId;
  final String? originStationId;
  final String? destinationStationId;
  final LatLng? riderLocation;
  final double? riderHeading;
  final bool showDirectionIndicator;
  final bool trackLiveLocation;
  final double? geofenceRadiusMeters;
  final List<LatLng>? routePoints;

  const SharedBikeMap({
    super.key,
    required this.stations,
    this.isAdminMode = false,
    this.onStationTap,
    this.onMapLongPress,
    this.initialCenter,
    this.initialZoom = 14.0,
    this.selectedStationId,
    this.originStationId,
    this.destinationStationId,
    this.riderLocation,
    this.riderHeading,
    this.showDirectionIndicator = true,
    this.trackLiveLocation = false,
    this.geofenceRadiusMeters,
    this.routePoints,
  });

  @override
  State<SharedBikeMap> createState() => SharedBikeMapState();
}

class SharedBikeMapState extends State<SharedBikeMap> {
  final MapController _mapController = MapController();
  LatLng? _currentGpsLocation;
  double? _currentGpsHeading;
  StreamSubscription<Position>? _gpsStreamSub;

  @override
  void initState() {
    super.initState();
    if (widget.initialCenter == null) {
      recenterToGps();
    }
    if (widget.trackLiveLocation && (widget.riderLocation == null || widget.riderHeading == null)) {
      _startLiveGpsStream();
    }
  }

  void _startLiveGpsStream() {
    if (!widget.trackLiveLocation) return;
    _gpsStreamSub?.cancel();
    try {
      _gpsStreamSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
        ),
      ).listen(
            (Position pos) {
          if (!mounted) return;
          final newPos = LatLng(pos.latitude, pos.longitude);
          double? heading = pos.heading;
          if (heading == 0.0 && _currentGpsLocation != null) {
            final calcBearing = Geolocator.bearingBetween(
              _currentGpsLocation!.latitude,
              _currentGpsLocation!.longitude,
              newPos.latitude,
              newPos.longitude,
            );
            if (calcBearing != 0.0) heading = calcBearing;
          }
          setState(() {
            _currentGpsLocation = newPos;
            if (heading != 0.0) _currentGpsHeading = heading;
          });
        },
        onError: (_) {},
      );
    } catch (_) {}
  }

  void moveCameraToLocation(LatLng location, {double? zoom}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        _mapController.move(location, zoom ?? widget.initialZoom);
      } catch (e) {
        debugPrint("Map camera move error: $e");
      }
    });
  }

  void fitBounds(List<LatLng> points, {EdgeInsets? padding}) {
    if (points.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final bounds = LatLngBounds.fromPoints(points);
        _mapController.fitCamera(
          CameraFit.bounds(
            bounds: bounds,
            padding: padding ??
                const EdgeInsets.only(
                  top: 120.0,
                  bottom: 280.0,
                  left: 60.0,
                  right: 60.0,
                ),
          ),
        );
      } catch (e) {
        debugPrint("Map fitBounds error: $e");
      }
    });
  }

  @override
  void didUpdateWidget(covariant SharedBikeMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedStationId != oldWidget.selectedStationId && widget.selectedStationId != null) {
      _centerOnSelectedStation(widget.selectedStationId!);
    }
    if (widget.trackLiveLocation != oldWidget.trackLiveLocation ||
        widget.riderLocation != oldWidget.riderLocation ||
        widget.riderHeading != oldWidget.riderHeading) {
      if (widget.trackLiveLocation && (widget.riderLocation == null || widget.riderHeading == null)) {
        if (_gpsStreamSub == null) _startLiveGpsStream();
      } else if (!widget.trackLiveLocation) {
        _gpsStreamSub?.cancel();
        _gpsStreamSub = null;
      }
    }
  }

  @override
  void dispose() {
    _gpsStreamSub?.cancel();
    super.dispose();
  }

  void _centerOnSelectedStation(String stationId) {
    for (final s in widget.stations) {
      if (s['id']?.toString() == stationId || s['code']?.toString() == stationId) {
        final double? lat = _toDouble(s['latitude'] ?? s['lat']);
        final double? lng = _toDouble(s['longitude'] ?? s['lng']);
        if (lat != null && lng != null) {
          moveCameraToLocation(LatLng(lat, lng));
          break;
        }
      }
    }
  }

  Future<void> recenterToGps() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) return;

    try {
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      final userLatLng = LatLng(position.latitude, position.longitude);

      if (mounted) {
        setState(() {
          _currentGpsLocation = userLatLng;
          if (position.heading != 0.0) {
            _currentGpsHeading = position.heading;
          }
        });
        moveCameraToLocation(userLatLng);
      }
    } catch (e) {
      debugPrint("GPS location fetch error: $e");
    }
  }

  LatLng _computeInitialCenter() {
    if (widget.initialCenter != null) return widget.initialCenter!;

    if (widget.selectedStationId != null) {
      for (final s in widget.stations) {
        if (s['id']?.toString() == widget.selectedStationId) {
          final lat = _toDouble(s['latitude'] ?? s['lat']);
          final lng = _toDouble(s['longitude'] ?? s['lng']);
          if (lat != null && lng != null) return LatLng(lat, lng);
        }
      }
    }

    if (widget.riderLocation != null) return widget.riderLocation!;
    if (_currentGpsLocation != null) return _currentGpsLocation!;

    for (final s in widget.stations) {
      final lat = _toDouble(s['latitude'] ?? s['lat']);
      final lng = _toDouble(s['longitude'] ?? s['lng']);
      if (lat != null && lng != null) return LatLng(lat, lng);
    }

    return const LatLng(5.4643, 100.2841);
  }

  static double? _toDouble(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    return double.tryParse(val.toString());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final center = _computeInitialCenter();

    LatLng? selectedLatLng;
    if (widget.selectedStationId != null && widget.geofenceRadiusMeters != null) {
      for (final s in widget.stations) {
        if (s['id']?.toString() == widget.selectedStationId) {
          final lat = _toDouble(s['latitude'] ?? s['lat']);
          final lng = _toDouble(s['longitude'] ?? s['lng']);
          if (lat != null && lng != null) {
            selectedLatLng = LatLng(lat, lng);
            break;
          }
        }
      }
    }

    final LatLng? effectiveRiderLocation = widget.riderLocation ?? _currentGpsLocation;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: center,
        initialZoom: widget.initialZoom,
        onLongPress: (tapPosition, point) {
          if (widget.isAdminMode && widget.onMapLongPress != null) {
            widget.onMapLongPress!(point);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.zvyap.edu.mobile.bike_renting_app',
        ),

        if (widget.routePoints != null && widget.routePoints!.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: widget.routePoints!,
                strokeWidth: 5.0,
                color: const Color(0xFF10B981),
              ),
            ],
          ),

        if (selectedLatLng != null && widget.geofenceRadiusMeters != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: selectedLatLng,
                radius: widget.geofenceRadiusMeters!,
                useRadiusInMeter: true,
                color: colorScheme.secondary.withValues(alpha: 0.18),
                borderColor: colorScheme.secondary,
                borderStrokeWidth: 2.0,
              ),
            ],
          ),

        Builder(
          builder: (context) {
            final zoom = MapCamera.of(context).zoom;
            final double dynamicMarkerSize = (zoom * 4.5).clamp(44.0, 68.0);

            return MarkerLayer(
              markers: _buildMarkers(context, dynamicMarkerSize, effectiveRiderLocation),
            );
          },
        ),
      ],
    );
  }

  List<Marker> _buildMarkers(BuildContext context, double markerSize, LatLng? activeRiderLocation) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Marker> markers = [];

    final LatLng? effectiveRider = activeRiderLocation ?? _currentGpsLocation;
    final double? effectiveHeading = widget.riderHeading ?? _currentGpsHeading;

    if (effectiveRider != null) {
      markers.add(
        Marker(
          point: effectiveRider,
          width: 72,
          height: 72,
          alignment: Alignment.center,
          child: GoogleMapsLocationMarker(
            heading: widget.showDirectionIndicator ? effectiveHeading : null,
            markerColor: colorScheme.primary,
          ),
        ),
      );
    }

    for (final station in widget.stations) {
      final double? lat = _toDouble(station['latitude'] ?? station['lat']);
      final double? lng = _toDouble(station['longitude'] ?? station['lng']);
      if (lat == null || lng == null) continue;

      final String stationId = station['id']?.toString() ?? '';
      final String stationCode = station['code']?.toString() ?? '';
      final String status = station['status']?.toString() ?? 'Normal';

      // Skip rendering markers for Terminated stations in User View (when isAdminMode is false)
      if (!widget.isAdminMode && status.trim().toLowerCase() == 'terminated') {
        continue;
      }

      final bool isOrigin = widget.originStationId != null &&
          widget.originStationId!.isNotEmpty &&
          (stationId == widget.originStationId || stationCode == widget.originStationId);

      final bool isDestination = widget.destinationStationId != null &&
          widget.destinationStationId!.isNotEmpty &&
          (stationId == widget.destinationStationId || stationCode == widget.destinationStationId);

      final bool isSelected = (widget.selectedStationId != null &&
          (stationId == widget.selectedStationId || stationCode == widget.selectedStationId)) ||
          isOrigin ||
          isDestination;

      // Base status color calculation
      Color markerColor = const Color(0xFF10B981);
      if (status == 'Under Maintenance') {
        markerColor = const Color(0xFFF97316);
      } else if (status == 'Terminated' || (widget.isAdminMode && status != 'Normal')) {
        markerColor = const Color(0xFFDC2626);
      }

      // Hard OVERRIDE for active route planner selection: Origin = Emerald Green, Destination = Royal Blue
      if (isOrigin) {
        markerColor = const Color(0xFF10B981);
      } else if (isDestination) {
        markerColor = const Color(0xFF2563EB);
      }

      final double effectiveSize = isSelected ? markerSize * 1.25 : markerSize;

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: effectiveSize,
          height: effectiveSize,
          rotate: true,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () {
              if (widget.onStationTap != null && stationId.isNotEmpty) {
                widget.onStationTap!(stationId);
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  size: effectiveSize,
                  color: markerColor,
                ),
                if (isSelected)
                  Positioned(
                    top: effectiveSize * 0.16,
                    child: Container(
                      width: effectiveSize * 0.36,
                      height: effectiveSize * 0.36,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOrigin
                            ? Icons.check
                            : (isDestination ? Icons.flag : Icons.check),
                        size: effectiveSize * 0.28,
                        color: markerColor,
                      ),
                    ),
                  )
                else if (status.trim().toLowerCase() == 'under maintenance')
                  Positioned(
                    top: effectiveSize * 0.16,
                    child: Container(
                      width: effectiveSize * 0.36,
                      height: effectiveSize * 0.36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFF97316),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.build_rounded,
                        size: effectiveSize * 0.22,
                        color: const Color(0xFFF97316),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return markers;
  }
}

/// Google Maps styled current location marker.
/// Includes pulsing accuracy aura, crisp white-bordered blue dot,
/// and directional beam (field of view cone) pointing towards heading.
class GoogleMapsLocationMarker extends StatelessWidget {
  final double? heading;
  final Color? markerColor;

  const GoogleMapsLocationMarker({
    super.key,
    this.heading,
    this.markerColor,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = markerColor ?? const Color(0xFF4285F4);

    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Google Maps directional beam (field of view cone)
          if (heading != null)
            Transform.rotate(
              angle: heading! * (math.pi / 180.0),
              child: CustomPaint(
                size: const Size(72, 72),
                painter: _GoogleMapsBeamPainter(color: themeColor),
              ),
            ),

          // 2. Translucent accuracy/halo circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: themeColor.withValues(alpha: 0.18),
            ),
          ),

          // 3. Crisp white circular border with subtle elevation
          Container(
            width: 18,
            height: 18,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            alignment: Alignment.center,
            // 4. Solid Google Maps blue dot
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: themeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleMapsBeamPainter extends CustomPainter {
  final Color color;

  const _GoogleMapsBeamPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: 0.50),
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.15, 0.55, 1.0],
      ).createShader(rect);

    // 60-degree beam pointing North (-pi/2)
    final path = ui.Path()
      ..moveTo(center.dx, center.dy)
      ..arcTo(rect, -math.pi / 2 - (math.pi / 6), math.pi / 3, false)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _GoogleMapsBeamPainter oldDelegate) =>
      oldDelegate.color != color;
}