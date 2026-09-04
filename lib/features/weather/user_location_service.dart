import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import 'package:bike_renting_app/features/weather/weather_api_service.dart';

/// Resolved location data suited for weather forecast queries and UI display.
class UserWeatherLocation {
  const UserWeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.stateName,
    required this.forecastLocationName,
    this.forecastLocationId,
    this.fallbackCandidates = const [],
  });

  final double latitude;
  final double longitude;
  final String cityName;
  final String stateName;
  final String forecastLocationName;
  final String? forecastLocationId;
  final List<String> fallbackCandidates;

  String get displayName => '$cityName, $stateName';
}

/// Known weather forecast stations and regional centers across Malaysian states and territories.
class _WeatherStationCoord {
  const _WeatherStationCoord({
    required this.id,
    required this.name,
    required this.state,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final String state;
  final double latitude;
  final double longitude;
}

/// Service that acquires device GPS coordinates and maps them dynamically to
/// Malaysian weather forecast locations (towns, districts, and states) supported
/// by api.data.gov.my.
class UserLocationService {
  UserLocationService({
    this.positionProvider,
    http.Client? client,
  }) : _client = client ?? http.Client();

  final Future<Position?> Function()? positionProvider;
  final http.Client _client;

  /// Prominent Malaysian weather forecast stations and administrative centers
  /// covering Peninsular and East Malaysia.
  static const List<_WeatherStationCoord> _stations = [
    // Penang (Pulau Pinang)
    _WeatherStationCoord(id: 'Tn018', name: 'Bukit Mertajam', state: 'Penang', latitude: 5.3637, longitude: 100.4659),
    _WeatherStationCoord(id: 'Tn014', name: 'Butterworth', state: 'Penang', latitude: 5.3991, longitude: 100.3638),
    _WeatherStationCoord(id: 'Tn015', name: 'Bayan Lepas', state: 'Penang', latitude: 5.2954, longitude: 100.2644),
    _WeatherStationCoord(id: 'St003', name: 'George Town', state: 'Penang', latitude: 5.4164, longitude: 100.3327),

    // Kedah & Perlis
    _WeatherStationCoord(id: 'Ds001', name: 'Langkawi', state: 'Kedah', latitude: 6.3500, longitude: 99.8000),
    _WeatherStationCoord(id: 'Tn001', name: 'Alor Setar', state: 'Kedah', latitude: 6.1248, longitude: 100.3678),
    _WeatherStationCoord(id: 'Tn004', name: 'Sungai Petani', state: 'Kedah', latitude: 5.6470, longitude: 100.4877),
    _WeatherStationCoord(id: 'Tn005', name: 'Kulim', state: 'Kedah', latitude: 5.3647, longitude: 100.5618),
    _WeatherStationCoord(id: 'Tn179', name: 'Kangar', state: 'Perlis', latitude: 6.4414, longitude: 100.1986),

    // Perak
    _WeatherStationCoord(id: 'Tn021', name: 'Ipoh', state: 'Perak', latitude: 4.5975, longitude: 101.0901),
    _WeatherStationCoord(id: 'Tn020', name: 'Taiping', state: 'Perak', latitude: 4.8500, longitude: 100.7333),
    _WeatherStationCoord(id: 'Tn024', name: 'Teluk Intan', state: 'Perak', latitude: 4.0259, longitude: 101.0213),

    // Klang Valley / Selangor / KL / Putrajaya
    _WeatherStationCoord(id: 'St014', name: 'Kuala Lumpur', state: 'Kuala Lumpur', latitude: 3.1390, longitude: 101.6869),
    _WeatherStationCoord(id: 'Tn061', name: 'Petaling Jaya', state: 'Selangor', latitude: 3.1073, longitude: 101.6067),
    _WeatherStationCoord(id: 'Tn077', name: 'Subang Jaya', state: 'Selangor', latitude: 3.0567, longitude: 101.5851),
    _WeatherStationCoord(id: 'Tn059', name: 'Shah Alam', state: 'Selangor', latitude: 3.0738, longitude: 101.5183),
    _WeatherStationCoord(id: 'Tn181', name: 'Klang', state: 'Selangor', latitude: 3.0449, longitude: 101.4456),
    _WeatherStationCoord(id: 'Tn171', name: 'Puchong', state: 'Selangor', latitude: 3.0333, longitude: 101.6167),
    _WeatherStationCoord(id: 'Tn087', name: 'Cyberjaya', state: 'Selangor', latitude: 2.9213, longitude: 101.6559),
    _WeatherStationCoord(id: 'Ds062', name: 'Putrajaya', state: 'Putrajaya', latitude: 2.9264, longitude: 101.6964),
    _WeatherStationCoord(id: 'Tn090', name: 'Kajang', state: 'Selangor', latitude: 2.9935, longitude: 101.7874),
    _WeatherStationCoord(id: 'Tn093', name: 'Seri Kembangan', state: 'Selangor', latitude: 3.0300, longitude: 101.7088),
    _WeatherStationCoord(id: 'Tn076', name: 'Rawang', state: 'Selangor', latitude: 3.3217, longitude: 101.5768),

    // Negeri Sembilan & Melaka
    _WeatherStationCoord(id: 'Tn074', name: 'Seremban', state: 'Negeri Sembilan', latitude: 2.7258, longitude: 101.9424),
    _WeatherStationCoord(id: 'Tn075', name: 'Port Dickson', state: 'Negeri Sembilan', latitude: 2.5228, longitude: 101.7959),
    _WeatherStationCoord(id: 'St004', name: 'Melaka', state: 'Melaka', latitude: 2.1896, longitude: 102.2501),

    // Johor
    _WeatherStationCoord(id: 'St001', name: 'Johor Bahru', state: 'Johor', latitude: 1.4927, longitude: 103.7414),
    _WeatherStationCoord(id: 'Tn080', name: 'Batu Pahat', state: 'Johor', latitude: 1.8548, longitude: 102.9325),
    _WeatherStationCoord(id: 'Tn079', name: 'Muar', state: 'Johor', latitude: 2.0442, longitude: 102.5689),
    _WeatherStationCoord(id: 'Tn081', name: 'Kluang', state: 'Johor', latitude: 2.0305, longitude: 103.3187),
    _WeatherStationCoord(id: 'Tn086', name: 'Mersing', state: 'Johor', latitude: 2.4312, longitude: 103.8405),

    // East Coast (Pahang, Terengganu, Kelantan)
    _WeatherStationCoord(id: 'St006', name: 'Kuantan', state: 'Pahang', latitude: 3.8077, longitude: 103.3260),
    _WeatherStationCoord(id: 'St011', name: 'Kuala Terengganu', state: 'Terengganu', latitude: 5.3117, longitude: 103.1324),
    _WeatherStationCoord(id: 'St002', name: 'Kota Bharu', state: 'Kelantan', latitude: 6.1254, longitude: 102.2386),

    // Sabah, Sarawak & Labuan
    _WeatherStationCoord(id: 'Tn187', name: 'Kuching', state: 'Sarawak', latitude: 1.5535, longitude: 110.3593),
    _WeatherStationCoord(id: 'Tn194', name: 'Miri', state: 'Sarawak', latitude: 4.4148, longitude: 114.0089),
    _WeatherStationCoord(id: 'Tn190', name: 'Sibu', state: 'Sarawak', latitude: 2.3000, longitude: 111.8167),
    _WeatherStationCoord(id: 'Tn193', name: 'Bintulu', state: 'Sarawak', latitude: 3.1667, longitude: 113.0333),
    _WeatherStationCoord(id: 'Tn196', name: 'Kota Kinabalu', state: 'Sabah', latitude: 5.9804, longitude: 116.0735),
    _WeatherStationCoord(id: 'Tn200', name: 'Sandakan', state: 'Sabah', latitude: 5.8402, longitude: 118.1179),
    _WeatherStationCoord(id: 'Tn201', name: 'Tawau', state: 'Sabah', latitude: 4.2498, longitude: 117.8871),
    _WeatherStationCoord(id: 'St015', name: 'Labuan', state: 'Labuan', latitude: 5.2831, longitude: 115.2308),
  ];

  /// Get current user location and map it to a forecast location.
  /// Throws [WeatherApiException] if GPS position is unavailable or outside Malaysia.
  /// NO fallback to any mock or default city!
  Future<UserWeatherLocation> getCurrentUserLocation() async {
    final provider = positionProvider;
    final position = provider != null
        ? await provider()
        : await _resolveDevicePosition();

    if (position == null) {
      throw const WeatherApiException(
        'GPS location unavailable. Please enable GPS and grant permission to get weather.',
      );
    }

    return resolveLocation(position.latitude, position.longitude);
  }

  /// Resolves location from coordinates dynamically.
  /// 1. Checks bounds for Malaysia (lat 0.5° - 8.0° N, lon 98.5° - 120.0° E).
  /// 2. Queries reverse geocoding to resolve exact town/district/state dynamically.
  /// 3. If reverse geocoding is unavailable or times out, matches nearest station in [_stations].
  Future<UserWeatherLocation> resolveLocation(double lat, double lon) async {
    // Strict Malaysia bounds check: do NOT pretend or fall back if outside Malaysia!
    if (lat < 0.5 || lat > 8.0 || lon < 98.5 || lon > 120.0) {
      throw WeatherApiException(
        'GPS location (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}) is outside Malaysia. Weather forecast only available in Malaysia.',
      );
    }

    try {
      final geocoded = await _reverseGeocode(lat, lon);
      if (geocoded != null) {
        return geocoded;
      }
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      debugPrint('Dynamic reverse geocode error: $e');
    }

    // Fall back to coordinate distance matching among known Malaysian stations
    return matchCoordinates(lat, lon);
  }

  /// Dynamically reverse geocodes coordinates via OpenStreetMap Nominatim.
  Future<UserWeatherLocation?> _reverseGeocode(double lat, double lon) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&zoom=14&addressdetails=1',
    );

    try {
      final response = await _client.get(
        url,
        headers: {
          'Accept': 'application/json',
          'User-Agent': 'BikeRentingApp/1.0 (Mobile Assignment; contact@bikerent.my)',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map<String, dynamic>) {
          final address = data['address'] as Map<String, dynamic>?;
          if (address != null) {
            final countryCode = address['country_code']?.toString().toLowerCase();
            if (countryCode != null && countryCode != 'my') {
              throw const WeatherApiException(
                'Location is outside Malaysia. Weather forecast only available in Malaysia.',
              );
            }

            final town = address['town'] ??
                address['city'] ??
                address['suburb'] ??
                address['village'] ??
                address['municipality'];
            final district = address['district'] ?? address['county'] ?? address['region'];
            final rawState = address['state']?.toString() ?? 'Malaysia';
            final state = rawState.replaceAll('Wilayah Persekutuan ', '').trim();

            final candidates = <String>[];
            if (town != null && town.toString().trim().isNotEmpty) {
              candidates.add(town.toString().trim());
            }
            if (district != null && district.toString().trim().isNotEmpty && district != town) {
              candidates.add(district.toString().trim());
            }
            if (state.isNotEmpty && !candidates.contains(state)) {
              candidates.add(state);
            }

            final primaryName = candidates.isNotEmpty ? candidates.first : state;
            final cityName = town?.toString() ?? district?.toString() ?? state;

            return UserWeatherLocation(
              latitude: lat,
              longitude: lon,
              cityName: cityName,
              stateName: state,
              forecastLocationName: primaryName,
              fallbackCandidates: candidates.skip(1).toList(),
            );
          }
        }
      }
    } catch (e) {
      if (e is WeatherApiException) rethrow;
      debugPrint('Reverse geocode request failed: $e');
    }
    return null;
  }

  /// Finds the closest Malaysian weather forecast station using Haversine formula.
  UserWeatherLocation matchCoordinates(double lat, double lon) {
    if (lat < 0.5 || lat > 8.0 || lon < 98.5 || lon > 120.0) {
      throw WeatherApiException(
        'GPS location (${lat.toStringAsFixed(2)}, ${lon.toStringAsFixed(2)}) is outside Malaysia. Weather forecast only available in Malaysia.',
      );
    }

    _WeatherStationCoord? closest;
    double minDistanceKm = double.infinity;

    for (final station in _stations) {
      final dist = _haversineDistance(lat, lon, station.latitude, station.longitude);
      if (dist < minDistanceKm) {
        minDistanceKm = dist;
        closest = station;
      }
    }

    if (closest == null) {
      throw const WeatherApiException('Unable to determine Malaysian weather station.');
    }

    return UserWeatherLocation(
      latitude: lat,
      longitude: lon,
      cityName: closest.name,
      stateName: closest.state,
      forecastLocationName: closest.name,
      forecastLocationId: closest.id,
      fallbackCandidates: [closest.state],
    );
  }

  /// Queries Geolocator device location with permission and service checks.
  Future<Position?> _resolveDevicePosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      try {
        return await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            timeLimit: Duration(seconds: 4),
          ),
        );
      } catch (_) {
        return await Geolocator.getLastKnownPosition();
      }
    } catch (e) {
      debugPrint('Device position check failed: $e');
      return null;
    }
  }

  /// Calculates great-circle distance between two coordinates in kilometers.
  static double _haversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const r = 6371.0; // Earth radius in km
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
}
