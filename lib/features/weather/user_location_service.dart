import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Resolved location data suited for weather forecast queries and UI display.
class UserWeatherLocation {
  const UserWeatherLocation({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.stateName,
    required this.forecastLocationName,
    this.forecastLocationId,
  });

  final double latitude;
  final double longitude;
  final String cityName;
  final String stateName;
  final String forecastLocationName;
  final String? forecastLocationId;

  String get displayName => '$cityName, $stateName';

  /// Default fallback location matching user's reference: Bukit Mertajam, Penang.
  static const bukitMertajam = UserWeatherLocation(
    latitude: 5.3637,
    longitude: 100.4659,
    cityName: 'Bukit Mertajam',
    stateName: 'Penang',
    forecastLocationName: 'Bukit Mertajam',
    forecastLocationId: 'Tn018',
  );
}

/// Represents a known weather station / region from api.data.gov.my.
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

/// Service that acquires device GPS coordinates and maps them to the nearest
/// Malaysian weather forecast station.
class UserLocationService {
  UserLocationService({
    this.positionProvider,
  });

  final Future<Position?> Function()? positionProvider;

  /// Curated list of prominent Malaysian weather forecast stations with coordinates.
  static const List<_WeatherStationCoord> _stations = [
    // Penang (Pulau Pinang)
    _WeatherStationCoord(
      id: 'Tn018',
      name: 'Bukit Mertajam',
      state: 'Penang',
      latitude: 5.3637,
      longitude: 100.4659,
    ),
    _WeatherStationCoord(
      id: 'Tn014',
      name: 'Butterworth',
      state: 'Penang',
      latitude: 5.3991,
      longitude: 100.3638,
    ),
    _WeatherStationCoord(
      id: 'Tn015',
      name: 'Bayan Lepas',
      state: 'Penang',
      latitude: 5.2954,
      longitude: 100.2644,
    ),
    _WeatherStationCoord(
      id: 'St003',
      name: 'Pulau Pinang',
      state: 'Penang',
      latitude: 5.4164,
      longitude: 100.3327,
    ),
    // Kedah & Perlis
    _WeatherStationCoord(
      id: 'Ds001',
      name: 'Langkawi',
      state: 'Kedah',
      latitude: 6.3500,
      longitude: 99.8000,
    ),
    _WeatherStationCoord(
      id: 'Tn001',
      name: 'Alor Setar',
      state: 'Kedah',
      latitude: 6.1248,
      longitude: 100.3678,
    ),
    _WeatherStationCoord(
      id: 'Tn179',
      name: 'Kangar',
      state: 'Perlis',
      latitude: 6.4414,
      longitude: 100.1986,
    ),
    // Perak
    _WeatherStationCoord(
      id: 'Tn021',
      name: 'Ipoh',
      state: 'Perak',
      latitude: 4.5975,
      longitude: 101.0901,
    ),
    _WeatherStationCoord(
      id: 'Tn020',
      name: 'Taiping',
      state: 'Perak',
      latitude: 4.8500,
      longitude: 100.7333,
    ),
    // Klang Valley / Selangor / KL
    _WeatherStationCoord(
      id: 'St014',
      name: 'Kuala Lumpur',
      state: 'Kuala Lumpur',
      latitude: 3.1390,
      longitude: 101.6869,
    ),
    _WeatherStationCoord(
      id: 'Tn061',
      name: 'Petaling Jaya',
      state: 'Selangor',
      latitude: 3.1073,
      longitude: 101.6067,
    ),
    _WeatherStationCoord(
      id: 'Tn059',
      name: 'Shah Alam',
      state: 'Selangor',
      latitude: 3.0738,
      longitude: 101.5183,
    ),
    _WeatherStationCoord(
      id: 'Tn181',
      name: 'Klang',
      state: 'Selangor',
      latitude: 3.0449,
      longitude: 101.4456,
    ),
    // Negeri Sembilan & Melaka
    _WeatherStationCoord(
      id: 'Tn074',
      name: 'Seremban',
      state: 'Negeri Sembilan',
      latitude: 2.7258,
      longitude: 101.9424,
    ),
    _WeatherStationCoord(
      id: 'St004',
      name: 'Melaka',
      state: 'Melaka',
      latitude: 2.1896,
      longitude: 102.2501,
    ),
    // Johor
    _WeatherStationCoord(
      id: 'St001',
      name: 'Johor Bahru',
      state: 'Johor',
      latitude: 1.4927,
      longitude: 103.7414,
    ),
    _WeatherStationCoord(
      id: 'Tn080',
      name: 'Batu Pahat',
      state: 'Johor',
      latitude: 1.8548,
      longitude: 102.9325,
    ),
    // East Coast
    _WeatherStationCoord(
      id: 'St006',
      name: 'Kuantan',
      state: 'Pahang',
      latitude: 3.8077,
      longitude: 103.3260,
    ),
    _WeatherStationCoord(
      id: 'St011',
      name: 'Kuala Terengganu',
      state: 'Terengganu',
      latitude: 5.3117,
      longitude: 103.1324,
    ),
    _WeatherStationCoord(
      id: 'St002',
      name: 'Kota Bharu',
      state: 'Kelantan',
      latitude: 6.1254,
      longitude: 102.2386,
    ),
    // Sabah & Sarawak
    _WeatherStationCoord(
      id: 'Tn187',
      name: 'Kuching',
      state: 'Sarawak',
      latitude: 1.5535,
      longitude: 110.3593,
    ),
    _WeatherStationCoord(
      id: 'Tn194',
      name: 'Miri',
      state: 'Sarawak',
      latitude: 4.4148,
      longitude: 114.0089,
    ),
    _WeatherStationCoord(
      id: 'Tn196',
      name: 'Kota Kinabalu',
      state: 'Sabah',
      latitude: 5.9804,
      longitude: 116.0735,
    ),
    _WeatherStationCoord(
      id: 'Tn200',
      name: 'Sandakan',
      state: 'Sabah',
      latitude: 5.8402,
      longitude: 118.1179,
    ),
  ];

  /// Get current user location and map it to a forecast location.
  /// Falls back to Bukit Mertajam, Penang if permission is denied or location is unavailable.
  Future<UserWeatherLocation> getCurrentUserLocation() async {
    try {
      final provider = positionProvider;
      final position = provider != null
          ? await provider()
          : await _resolveDevicePosition();

      if (position == null) {
        return UserWeatherLocation.bukitMertajam;
      }

      return matchCoordinates(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('UserLocationService error: $e');
      return UserWeatherLocation.bukitMertajam;
    }
  }

  /// Finds the closest weather forecast station using Haversine formula.
  UserWeatherLocation matchCoordinates(double lat, double lon) {
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
      return UserWeatherLocation.bukitMertajam;
    }

    return UserWeatherLocation(
      latitude: lat,
      longitude: lon,
      cityName: closest.name,
      stateName: closest.state,
      forecastLocationName: closest.name,
      forecastLocationId: closest.id,
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
