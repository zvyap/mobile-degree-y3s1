import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:bike_renting_app/features/weather/open_meteo_service.dart';
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

  bool isExpired(Duration ttl, DateTime now) {
    return now.difference(cachedAt) > ttl;
  }
}

/// Categorized weather error types for semantic UI representation.
enum WeatherErrorType {
  network,
  timeout,
  rateLimit,
  serverError,
  locationUnavailable,
  outsideMalaysia,
  notFound,
  unknown,
}

/// Exception thrown when weather forecast retrieval fails.
class WeatherApiException implements Exception {
  const WeatherApiException(
    this.message, {
    this.statusCode,
    this.isRateLimit = false,
    this.errorType = WeatherErrorType.unknown,
    this.technicalDetails,
  });

  final String message;
  final int? statusCode;
  final bool isRateLimit;
  final WeatherErrorType errorType;
  final String? technicalDetails;

  @override
  String toString() => message;
}

/// Service that composes ride conditions from the Malaysian government
/// weather forecast (api.data.gov.my) plus measured metrics from Open-Meteo,
/// converts raw responses into typed models, and caches snapshots.
class WeatherApiService {
  WeatherApiService({
    http.Client? client,
    OpenMeteoService? openMeteoService,
    this.cacheTtl = const Duration(minutes: 30),
    DateTime Function()? clock,
  })  : _client = client ?? http.Client(),
        _openMeteo = openMeteoService ??
            OpenMeteoService(client: client, clock: clock),
        _clock = clock ?? DateTime.now;

  static WeatherApiService? _shared;
  static WeatherApiService get shared => _shared ??= WeatherApiService();
  @visibleForTesting
  static set shared(WeatherApiService service) => _shared = service;

  static const String baseUrl = 'https://api.data.gov.my/weather/forecast/';

  final http.Client _client;
  final OpenMeteoService _openMeteo;
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
      ).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Weather API fetch failed: $e');
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('timeoutexception') || errStr.contains('timed out')) {
        throw WeatherApiException(
          'Weather service took too long to respond. Please check your connection and try again.',
          errorType: WeatherErrorType.timeout,
          technicalDetails: e.toString(),
        );
      }
      throw WeatherApiException(
        'Unable to connect to weather service. Please check your internet connection and try again.',
        errorType: WeatherErrorType.network,
        technicalDetails: e.toString(),
      );
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
        throw WeatherApiException(
          'Unable to read weather forecast data. Please try again later.',
          errorType: WeatherErrorType.unknown,
          technicalDetails: e.toString(),
        );
      }
      return const [];
    } else if (response.statusCode == 429) {
      debugPrint('Weather API rate limit (429): ${response.body}');
      throw const WeatherApiException(
        'Too many requests. Please wait a moment before trying again.',
        statusCode: 429,
        isRateLimit: true,
        errorType: WeatherErrorType.rateLimit,
      );
    } else if (response.statusCode >= 500) {
      debugPrint('Weather API error ${response.statusCode}: ${response.body}');
      throw WeatherApiException(
        'Weather service is temporarily unavailable. Please try again later.',
        statusCode: response.statusCode,
        errorType: WeatherErrorType.serverError,
      );
    } else {
      debugPrint('Weather API error ${response.statusCode}: ${response.body}');
      throw WeatherApiException(
        'Weather service unavailable right now. Please try again later.',
        statusCode: response.statusCode,
        errorType: WeatherErrorType.serverError,
      );
    }
  }

  /// Get live ride conditions snapshot for the given user location.
  ///
  /// The api.data.gov.my forecast always drives the weather conditions and
  /// periods; Open-Meteo supplies the measured metrics on a best-effort basis.
  /// Uses cached result if within TTL; otherwise queries both services.
  Future<WeatherSnapshot> getRideConditions(
    UserWeatherLocation location, {
    bool forceRefresh = false,
  }) async {
    final now = _clock();
    final cacheKey = location.forecastLocationName.toLowerCase().trim();

    if (!forceRefresh) {
      final cached = _cache[cacheKey];
      if (cached != null && !cached.isExpired(cacheTtl, now)) {
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
        'No weather forecast available for ${location.displayName}.',
        errorType: WeatherErrorType.notFound,
      );
    }

    final snapshot = await _composeSnapshot(
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

  /// Composes a [WeatherSnapshot]: the government forecast drives the current
  /// and next-hour conditions, while Open-Meteo fills the measured metrics.
  /// If Open-Meteo fails for any reason the government-only snapshot is
  /// returned with null metrics so the UI can degrade gracefully.
  Future<WeatherSnapshot> _composeSnapshot(
    UserWeatherLocation location,
    List<DailyWeatherForecast> forecasts,
    DateTime now, {
    String? displayNameOverride,
  }) async {
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

    OpenMeteoConditions? metrics;
    try {
      metrics = await _openMeteo.fetchConditions(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (e) {
      debugPrint('Open-Meteo metrics unavailable, using gov forecast only: $e');
    }

    return WeatherSnapshot(
      locationName: displayNameOverride ?? location.displayName,
      currentCondition: currentCondition,
      nextHourCondition: nextHourCondition,
      currentTemperature: metrics?.currentTemperature?.round(),
      feelsLikeTemperature: metrics?.feelsLikeTemperature?.round(),
      nextHourTemperature: metrics?.nextHourTemperature?.round(),
      nextHourRainChance: metrics?.nextHourRainChance,
      humidityPercent: metrics?.humidityPercent,
      airQualityIndex: metrics?.airQualityIndex,
      windSpeedKmh: metrics?.windSpeedKmh?.round(),
      windDirection: metrics?.windDirection,
      updatedAt: now,
      dailyForecasts: forecasts,
    );
  }

  /// Clear in-memory cache.
  void clearCache() {
    _cache.clear();
  }
}
