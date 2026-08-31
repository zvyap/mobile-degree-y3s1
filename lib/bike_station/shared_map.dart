import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; //
import 'package:latlong2/latlong.dart';

class SharedBikeMap extends StatelessWidget {
  final List<dynamic> stations; // Replace 'dynamic' with your Station model
  final bool isAdminMode;

  // Callbacks
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
        initialCenter: const LatLng(5.464, 100.284),
        initialZoom: 14.0,
        // Admin CRUD: Long-press on the map to get coordinates for a new station
        onLongPress: (tapPosition, point) {
          if (isAdminMode && onMapLongPress != null) {
            onMapLongPress!(point);
          }
        },
      ),
      children: [
        // 1. OpenStreetMap Base Layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', //
          // IMPORTANT: Replace this with your actual app package name
          userAgentPackageName: 'com.yourcompany.bikeapp', //
        ),

        // 2. Dynamic Markers Layer
        MarkerLayer(
          markers: _buildMarkers(),
        ),
      ],
    );
  }

  // Helper method to generate OSM pins dynamically
  List<Marker> _buildMarkers() {
    return stations.map((station) {
      return Marker(
        point: LatLng(station.lat, station.lng),
        width: 40.0,
        height: 40.0,
        child: GestureDetector(
          onTap: () {
            if (onStationTap != null) {
              onStationTap!(station.id);
            }
          },
          // Swap icons/colors based on Admin Mode and station status
          child: Icon(
            Icons.location_on,
            size: 40.0,
            color: (isAdminMode && station.needsMaintenance)
                ? Colors.orange
                : Colors.blue,
          ),
        ),
      );
    }).toList();
  }
}