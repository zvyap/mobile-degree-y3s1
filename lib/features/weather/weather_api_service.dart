import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:bike_renting_app/features/weather/user_location_service.dart';
import 'package:bike_renting_app/features/weather/weather_models.dart';

/// Cache entry for weather data.
class _CachedWeather {
  const _CachedWeather({
    required this.snapshot,
    required this.cachedAt,
  });

  final WeatherSnapshot snapshot;
  final DateTime cachedAt;

  bool isExpired(Duration ttl) {
    return DateTime.now().difference(cachedAt) > ttl;
  }
}

/// Exception thrown when weather forecast retrieval fails.
class WeatherApiException implements Exception {
  const WeatherApiException(
    this.message, {
    this.statusCode,
    this.isRateLimit = false,
  });

  final String message;
  final int? statusCode;
  final bool isRateLimit;

  @override
  String toString() => message;
}

/// Service that fetches Malaysian weather forecasts from api.data.gov.my,
/// converts raw responses into typed models, and caches snapshots.
class WeatherApiService {
  WeatherApiService({
    http.Client? client,
    this.cacheTtl = const Duration(minutes: 30),
    DateTime Function()? clock,
  })  : _client = client ?? http.Client(),
        _clock = clock ?? DateTime.now;

  static WeatherApiService? _shared;
  static WeatherApiService get shared => _shared ??= WeatherApiService();
  @visibleForTesting
  static set shared(WeatherApiService service) => _shared = service;

  static const String baseUrl = 'https://api.data.gov.my/weather/forecast/';

  final http.Client _client;
  final Duration cacheTtl;
  final DateTime Function() _clock;

  final Map<String, _CachedWeather> _cache = {};

  /// Fetch weather forecast for a location name from api.data.gov.my.
  Future<List<DailyWeatherForecast>> fetchDailyForecasts(String locationName) async {
    final query = Uri.encodeComponent(locationName);
    final url = Uri.parse('$baseUrl?contains=$query@location__location_name');

    final http.Response response;
    try {
      response = await _client.get(
        url,
        headers: {'Accept': 'application/json'},
      );
    } catch (e) {
      debugPrint('Weather API fetch failed: $e');
      throw WeatherApiException('Network error: $e');
    }

    if (response.statusCode == 200) {
      try {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(DailyWeatherForecast.fromJson)
              .toList();
        }
      } catch (e) {
        debugPrint('Weather API decode error: $e');
        throw WeatherApiException('Failed to parse weather data: $e');
      }
      return const [];
    } else if (response.statusCode == 429) {
      debugPrint('Weather API rate limit (429): ${response.body}');
      throw const WeatherApiException(
        'Rate limit reached (HTTP 429). Too many requests.',
        statusCode: 429,
        isRateLimit: true,
      );
    } else {
      debugPrint('Weather API error ${response.statusCode}: ${response.body}');
      throw WeatherApiException(
        'Weather service error (HTTP ${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get live ride conditions snapshot for the given user location.
  /// Uses cached result if within TTL; otherwise queries api.data.gov.my.
  Future<WeatherSnapshot> getRideConditions(
    UserWeatherLocation location, {
    bool forceRefresh = false,
  }) async {
    final now = _clock();
    final cacheKey = location.forecastLocationName.toLowerCase().trim();

    if (!forceRefresh) {
      final cached = _cache[cacheKey];
      if (cached != null && !cached.isExpired(cacheTtl)) {
        return cached.snapshot;
      }
    }

    var forecasts = await fetchDailyForecasts(location.forecastLocationName);
    var resolvedDisplayName = location.displayName;

    if (forecasts.isEmpty && location.fallbackCandidates.isNotEmpty) {
      for (final candidate in location.fallbackCandidates) {
        try {
          final candidateForecasts = await fetchDailyForecasts(candidate);
          if (candidateForecasts.isNotEmpty) {
            forecasts = candidateForecasts;
            resolvedDisplayName = '$candidate, ${location.stateName}';
            break;
          }
        } catch (_) {}
      }
    }

    if (forecasts.isEmpty) {
      throw WeatherApiException(
        'No weather forecast available for ${location.displayName}',
      );
    }

    final snapshot = _buildSnapshotFromForecasts(
      location,
      forecasts,
      now,
      displayNameOverride: resolvedDisplayName,
    );

    _cache[cacheKey] = _CachedWeather(
      snapshot: snapshot,
      cachedAt: now,
    );

    return snapshot;
  }

  /// Synthesize a WeatherSnapshot from the list of daily forecasts.
  WeatherSnapshot _buildSnapshotFromForecasts(
    UserWeatherLocation location,
    List<DailyWeatherForecast> forecasts,
    DateTime now, {
    String? displayNameOverride,
  }) {
    // Find today's forecast or take the first available
    final todayForecast = forecasts.firstWhere(
      (f) =>
          f.date.year == now.year &&
          f.date.month == now.month &&
          f.date.day == now.day,
      orElse: () => forecasts.first,
    );

    final currentCondition = todayForecast.conditionAt(now);
    final nextHourCondition = todayForecast.nextPeriodConditionAt(now);

    // Compute realistic diurnal temperature based on time of day
    final currentTemp = _estimateTemperature(
      minTemp: todayForecast.minTemp,
      maxTemp: todayForecast.maxTemp,
      hour: now.hour,
      minute: now.minute,
    );

    final humidity = currentCondition.baseHumidity;

    // Approximate heat index / feels-like based on temperature and humidity
    final feelsLike = _estimateFeelsLike(currentTemp, humidity);

    // Next hour temperature adjustment
    final nextHourTemp = now.hour >= 14 && now.hour <= 22
        ? currentTemp - 1
        : currentTemp + 1;

    final rainChance = nextHourCondition.defaultRainChance;
    final aqi = currentCondition.baseAqi;
    final aqiLabel = _aqiToLabel(aqi);
    final windKmh = currentCondition.baseWindKmh;
    const windDirection = 'SW';

    return WeatherSnapshot(
      locationName: displayNameOverride ?? location.displayName,
      currentCondition: currentCondition,
      currentTemperature: currentTemp,
      feelsLikeTemperature: feelsLike,
      nextHourCondition: nextHourCondition,
      nextHourTemperature: nextHourTemp,
      nextHourRainChance: rainChance,
      humidityPercent: humidity,
      airQualityIndex: aqi,
      airQualityLabel: aqiLabel,
      windSpeedKmh: windKmh,
      windDirection: windDirection,
      updatedAt: now,
      dailyForecasts: forecasts,
    );
  }

  /// Calculates diurnal temperature curve peaking around 14:00-15:00.
  static int _estimateTemperature({
    required int minTemp,
    required int maxTemp,
    required int hour,
    required int minute,
  }) {
    final double time = hour + (minute / 60.0);

    if (time >= 6.0 && time < 14.0) {
      final factor = (time - 6.0) / 8.0;
      return (minTemp + (maxTemp - minTemp) * factor).round();
    } else if (time >= 14.0 && time < 20.0) {
      final factor = (time - 14.0) / 6.0;
      return (maxTemp - (maxTemp - minTemp) * 0.6 * factor).round();
    } else if (time >= 20.0) {
      final factor = (time - 20.0) / 10.0;
      final nightStart = minTemp + ((maxTemp - minTemp) * 0.4);
      return (nightStart - (nightStart - minTemp) * factor).round();
    } else {
      // 0:00 to 6:00
      return minTemp + 1;
    }
  }

  /// Simple empirical feels-like calculation for tropical climates.
  static int _estimateFeelsLike(int temp, int humidity) {
    if (temp < 25) return temp;
    final excessHumidity = humidity - 60;
    if (excessHumidity <= 0) return temp;
    final boost = (excessHumidity * 0.12).round();
    return temp + boost;
  }

  static String _aqiToLabel(int aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 200) return 'Unhealthy';
    return 'Very Unhealthy';
  }

  /// Clear in-memory cache.
  void clearCache() {
    _cache.clear();
  }
}
