import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// 🟢 IMPORT YOUR STANDALONE STATION DETAILS FILE (Source 4)
import 'package:bike_renting_app/bike_station/station_details.dart';

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
  List<Map<String, dynamic>> stations = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  // Fetch active stations from Supabase
  Future<void> _fetchStations() async {
    setState(() => isLoading = true);
    try {
      final response = await supabase
          .from('stations')
          .select()
          .eq('is_active', true)
          .order('id', ascending: true);

      setState(() {
        stations = List<Map<String, dynamic>>.from(response);
        isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stations: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // 1. Shared Map Layer
          Positioned.fill(
            child: SharedBikeMap(
              stations: stations,
              isAdminMode: true,
              // LONG PRESS TO ADD NEW STATION
              onMapLongPress: (LatLng point) async {
                final isSaved = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StationDetailScreen(
                      initialLat: point.latitude,
                      initialLng: point.longitude,
                      isViewOnly: false, // Opens in Admin Add Mode
                    ),
                  ),
                );

                if (isSaved == true) {
                  _fetchStations(); // Refresh markers from Supabase
                }
              },
              // TAP MARKER TO EDIT EXISTING STATION
              onStationTap: (stationId) async {
                final selectedStation = stations.firstWhere(
                      (s) => s['id'].toString() == stationId,
                );

                final isSaved = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StationDetailScreen(
                      stationData: selectedStation,
                      isViewOnly: false, // Opens in Admin Edit Mode
                    ),
                  ),
                );

                if (isSaved == true) {
                  _fetchStations();
                }
              },
            ),
          ),

          // 2. Top Navigation Bar
          Positioned(
            top: 50.0,
            left: 16.0,
            right: 16.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: colorScheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    "Long-press map to add station",
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Refresh Floating Action Button
          Positioned(
            right: 16.0,
            bottom: 30.0,
            child: FloatingActionButton(
              backgroundColor: colorScheme.surfaceContainerHighest,
              onPressed: _fetchStations,
              child: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : Icon(Icons.refresh, color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 2. MAP COMPONENT: SharedBikeMap
// ============================================================================
// ============================================================================
// MAP COMPONENT: SharedBikeMap
// ============================================================================
// ============================================================================
// MAP COMPONENT: SharedBikeMap
// ============================================================================
class SharedBikeMap extends StatelessWidget {
  final List<Map<String, dynamic>> stations;
  final bool isAdminMode;
  final Function(String stationId)? onStationTap;
  final Function(LatLng coordinates)? onMapLongPress;
  final LatLng? initialCenter;
  final double initialZoom;
  final String? selectedStationId;
  final LatLng? riderLocation;
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
    this.riderLocation,
    this.geofenceRadiusMeters,
    this.routePoints,
  });

  LatLng _computeInitialCenter() {
    if (initialCenter != null) return initialCenter!;

    if (selectedStationId != null) {
      for (final s in stations) {
        if (s['id']?.toString() == selectedStationId) {
          final lat = _toDouble(s['latitude'] ?? s['lat']);
          final lng = _toDouble(s['longitude'] ?? s['lng']);
          if (lat != null && lng != null) return LatLng(lat, lng);
        }
      }
    }

    if (riderLocation != null) return riderLocation!;

    for (final s in stations) {
      final lat = _toDouble(s['latitude'] ?? s['lat']);
      final lng = _toDouble(s['longitude'] ?? s['lng']);
      if (lat != null && lng != null) return LatLng(lat, lng);
    }

    return const LatLng(5.4643, 100.2841); // Tanjung Bungah default
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

    // Find selected station coordinates for geofence circle
    LatLng? selectedLatLng;
    if (selectedStationId != null && geofenceRadiusMeters != null) {
      for (final s in stations) {
        if (s['id']?.toString() == selectedStationId) {
          final lat = _toDouble(s['latitude'] ?? s['lat']);
          final lng = _toDouble(s['longitude'] ?? s['lng']);
          if (lat != null && lng != null) {
            selectedLatLng = LatLng(lat, lng);
            break;
          }
        }
      }
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: center,
        initialZoom: initialZoom,
        onLongPress: (tapPosition, point) {
          if (isAdminMode && onMapLongPress != null) {
            onMapLongPress!(point);
          }
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.zvyap.edu.mobile.bike_renting_app',
        ),

        if (routePoints != null && routePoints!.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: routePoints!,
                strokeWidth: 5.0,
                color: const Color(0xFF10B981), // Vibrant Green Polyline
              ),
            ],
          ),

        // Optional geofence radius circle around selected station
        if (selectedLatLng != null && geofenceRadiusMeters != null)
          CircleLayer(
            circles: [
              CircleMarker(
                point: selectedLatLng,
                radius: geofenceRadiusMeters!,
                useRadiusInMeter: true,
                color: colorScheme.secondary.withValues(alpha: 0.18),
                borderColor: colorScheme.secondary,
                borderStrokeWidth: 2.0,
              ),
            ],
          ),

        // Dynamic markers for stations and rider
        Builder(
          builder: (context) {
            final zoom = MapCamera.of(context).zoom;
            final double dynamicMarkerSize = (zoom * 4.5).clamp(44.0, 68.0);

            return MarkerLayer(
              markers: _buildMarkers(context, dynamicMarkerSize),
            );
          },
        ),
      ],
    );
  }

  List<Marker> _buildMarkers(BuildContext context, double markerSize) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Marker> markers = [];

    // Rider position marker
    if (riderLocation != null) {
      markers.add(
        Marker(
          point: riderLocation!,
          width: 44,
          height: 44,
          alignment: Alignment.center,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
              ],
            ),
            child: const Icon(Icons.navigation, color: Colors.white, size: 20),
          ),
        ),
      );
    }

    for (final station in stations) {
      final double? lat = _toDouble(station['latitude'] ?? station['lat']);
      final double? lng = _toDouble(station['longitude'] ?? station['lng']);
      if (lat == null || lng == null) continue;

      final String stationId = station['id']?.toString() ?? '';
      final String status = station['status']?.toString() ?? 'Normal';
      final bool isSelected = selectedStationId != null &&
          (stationId == selectedStationId ||
              station['code']?.toString() == selectedStationId);

      Color markerColor = colorScheme.primary;
      if (isSelected) {
        markerColor = colorScheme.secondary;
      } else if (status == 'Under Maintenance') {
        markerColor = colorScheme.tertiary;
      } else if (status == 'Terminated' || (isAdminMode && status != 'Normal')) {
        markerColor = const Color(0xFFDC2626);
      }

      final double effectiveSize = isSelected ? markerSize * 1.2 : markerSize;

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: effectiveSize,
          height: effectiveSize,
          rotate: true,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onTap: () {
              if (onStationTap != null && stationId.isNotEmpty) {
                onStationTap!(stationId);
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
                        Icons.check,
                        size: effectiveSize * 0.28,
                        color: colorScheme.secondary,
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