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

  const SharedBikeMap({
    super.key,
    required this.stations,
    this.isAdminMode = false,
    this.onStationTap,
    this.onMapLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(5.4643, 100.2841), // Tanjung Bungah default
        initialZoom: 14.0,
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

        // 1. Dynamic scale builder based on current map zoom
        Builder(
          builder: (context) {
            final zoom = MapCamera.of(context).zoom;

            // 🔍 INCREASED SIZE RANGE: Capped between 48.0px and 72.0px
            final double dynamicMarkerSize = (zoom * 4.5).clamp(48.0, 72.0);

            return MarkerLayer(
              markers: _buildMarkers(context, dynamicMarkerSize),
            );
          },
        ),
      ],
    );
  }

  List<Marker> _buildMarkers(BuildContext context, double markerSize) {
    if (stations.isEmpty) return [];

    final colorScheme = Theme.of(context).colorScheme;
    final List<Marker> markers = [];

    for (final station in stations) {
      final rawLat = station['latitude'];
      final rawLng = station['longitude'];
      if (rawLat == null || rawLng == null) continue;

      final double? lat = (rawLat is num) ? rawLat.toDouble() : double.tryParse(rawLat.toString());
      final double? lng = (rawLng is num) ? rawLng.toDouble() : double.tryParse(rawLng.toString());
      if (lat == null || lng == null) continue;

      final String stationId = station['id']?.toString() ?? '';
      final String status = station['status']?.toString() ?? 'Normal';

      Color markerColor = colorScheme.primary;
      if (status == 'Under Maintenance') {
        markerColor = colorScheme.tertiary;
      } else if (status == 'Terminated' || (isAdminMode && status != 'Normal')) {
        markerColor = const Color(0xFFDC2626);
      }

      markers.add(
        Marker(
          point: LatLng(lat, lng),
          width: markerSize,
          height: markerSize,
          rotate: true, // Keeps marker upright on map rotation
          alignment: Alignment.topCenter, // Anchors pin tip to exact coordinates
          child: GestureDetector(
            onTap: () {
              if (onStationTap != null && stationId.isNotEmpty) {
                onStationTap!(stationId);
              }
            },
            child: Icon(
              Icons.location_on,
              size: markerSize,
              color: markerColor,
            ),
          ),
        ),
      );
    }

    return markers;
  }
}