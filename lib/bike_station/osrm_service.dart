import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class OsrmRouteResult {
  final List<LatLng> polylinePoints;
  final double distanceMeters;
  final double durationSeconds;

  OsrmRouteResult({
    required this.polylinePoints,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  double get distanceKm => distanceMeters / 1000.0;
  int get durationMinutes => (durationSeconds / 60).round();
}

class OsrmService {
  static Future<OsrmRouteResult?> fetchBikingRoute(LatLng start, LatLng end) async {
    final String url =
        'https://router.project-osrm.org/route/v1/biking/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List;
        if (routes.isEmpty) return null;

        final route = routes.first;
        final geometry = route['geometry']['coordinates'] as List;
        final double distance = (route['distance'] as num).toDouble();
        final double duration = (route['duration'] as num).toDouble();

        List<LatLng> points = geometry.map((coord) {
          return LatLng((coord[1] as num).toDouble(), (coord[0] as num).toDouble());
        }).toList();

        return OsrmRouteResult(
          polylinePoints: points,
          distanceMeters: distance,
          durationSeconds: duration,
        );
      }
    } catch (e) {
      debugPrint('OSRM Route Error: $e');
    }
    return null;
  }
}