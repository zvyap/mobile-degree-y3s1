import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'package:bike_renting_app/features/weather/weather_api_service.dart';

/// Measured weather metrics fetched from Open-Meteo.
///
/// All fields are nullable because Open-Meteo may omit measurements; the
/// consumer degrades gracefully by hiding the affected UI. The Malaysian
/// government API (api.data.gov.my) remains the primary source for weather
/// conditions — Open-Meteo only supplies the measured metrics the government
/// forecast does not provide.
class OpenMeteoConditions {
  const OpenMeteoConditions({
    this.currentTemperature,
    this.feelsLikeTemperature,
    this.humidityPercent,
    this.windSpeedKmh,
    this.windDirection,
    this.nextHourTemperature,
    this.nextHourRainChance,
    this.airQualityIndex,
  });

  /// Measured temperature at 2 m above ground, in °C.
  final double? currentTemperature;

  /// Measured apparent (feels-like) temperature, in °C.
  final double? feelsLikeTemperature;

  /// Measured relative humidity, in percent.
  final int? humidityPercent;

  /// Measured wind speed at 10 m above ground, in km/h.
  final double? windSpeedKmh;

  /// Compass direction (N/NE/E/SE/S/SW/W/NW) derived from the measured
  /// wind direction in degrees.
  final String? windDirection;

  /// Forecast temperature for the hour after now, in °C.
  final double? nextHourTemperature;

  /// Forecast precipitation probability for the hour after now, in percent.
  final int? nextHourRainChance;

  /// Measured US Air Quality Index.
  final int? airQualityIndex;
}

/// Service that fetches measured weather metrics from Open-Meteo's free,
/// keyless endpoints (https://open-meteo.com).
class OpenMeteoService {
  OpenMeteoService({http.Client? client, DateTime Function()? clock})
    : _client = client ?? http.Client(),
      _clock = clock ?? DateTime.now;

  static const String forecastBaseUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String airQualityBaseUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality';

  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;
  final DateTime Function() _clock;

  /// Fetches current measured metrics plus next-hour temp/rain chance and the
  /// US AQI for the given coordinates.
  ///
  /// The air-quality endpoint is treated as best-effort: a failure there only
  /// yields a null [OpenMeteoConditions.airQualityIndex], while a forecast
  /// failure throws [WeatherApiException].
  Future<OpenMeteoConditions> fetchConditions({
    required double latitude,
    required double longitude,
  }) async {
    final forecast = await _getJson(
      Uri.parse(
        '$forecastBaseUrl'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&current=temperature_2m,relative_humidity_2m,apparent_temperature,'
            'wind_speed_10m,wind_direction_10m'
        '&hourly=temperature_2m,precipitation_probability'
        '&forecast_days=2'
        '&timezone=auto',
      ),
      'Open-Meteo forecast',
    );
    final current = forecast['current'] as Map<String, dynamic>? ?? {};

    int? airQualityIndex;
    try {
      final air = await _getJson(
        Uri.parse(
          '$airQualityBaseUrl'
          '?latitude=$latitude'
          '&longitude=$longitude'
          '&current=us_aqi'
          '&timezone=auto',
        ),
        'Open-Meteo air quality',
      );
      final airCurrent = air['current'] as Map<String, dynamic>? ?? {};
      airQualityIndex = _toInt(airCurrent['us_aqi']);
    } catch (e) {
      debugPrint('Open-Meteo air quality unavailable: $e');
    }

    final (nextHourTemperature, nextHourRainChance) = _nextHourValues(forecast);

    return OpenMeteoConditions(
      currentTemperature: _toDouble(current['temperature_2m']),
      feelsLikeTemperature: _toDouble(current['apparent_temperature']),
      humidityPercent: _toInt(current['relative_humidity_2m']),
      windSpeedKmh: _toDouble(current['wind_speed_10m']),
      windDirection: _compassFromDegrees(
        (current['wind_direction_10m'] as num?)?.toDouble(),
      ),
      nextHourTemperature: nextHourTemperature,
      nextHourRainChance: nextHourRainChance,
      airQualityIndex: airQualityIndex,
    );
  }

  /// Reads the hourly temperature and precipitation probability for the hour
  /// after now. Open-Meteo returns hourly stamps in the location's timezone,
  /// which matches device-local time for the Malaysia-only target.
  (double?, int?) _nextHourValues(Map<String, dynamic> forecast) {
    final hourly = forecast['hourly'] as Map<String, dynamic>?;
    if (hourly == null) return (null, null);

    final times = hourly['time'] as List<dynamic>?;
    if (times == null || times.isEmpty) return (null, null);

    final target = _clock().add(const Duration(hours: 1));
    final stamp =
        '${target.year.toString().padLeft(4, '0')}-'
        '${target.month.toString().padLeft(2, '0')}-'
        '${target.day.toString().padLeft(2, '0')}T'
        '${target.hour.toString().padLeft(2, '0')}:00';
    final index = times.indexOf(stamp);
    if (index < 0) return (null, null);

    final temps = hourly['temperature_2m'] as List<dynamic>?;
    final rainChance = hourly['precipitation_probability'] as List<dynamic>?;
    return (
      index < (temps?.length ?? 0) ? _toDouble(temps?[index]) : null,
      index < (rainChance?.length ?? 0) ? _toInt(rainChance?[index]) : null,
    );
  }

  /// Performs a GET request and decodes a JSON object response, mapping
  /// failures to [WeatherApiException] with a matching [WeatherErrorType].
  Future<Map<String, dynamic>> _getJson(Uri uri, String label) async {
    final http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);
    } catch (e) {
      debugPrint('$label request failed: $e');
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('timeoutexception') || errStr.contains('timed out')) {
        throw WeatherApiException(
          'Weather metrics service took too long to respond.',
          errorType: WeatherErrorType.timeout,
          technicalDetails: e.toString(),
        );
      }
      throw WeatherApiException(
        'Unable to connect to weather metrics service.',
        errorType: WeatherErrorType.network,
        technicalDetails: e.toString(),
      );
    }

    if (response.statusCode == 200) {
      try {
        final dynamic decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic>) return decoded;
      } catch (e) {
        debugPrint('$label decode error: $e');
        throw WeatherApiException(
          'Unable to read weather metrics data.',
          errorType: WeatherErrorType.unknown,
          technicalDetails: e.toString(),
        );
      }
      throw const WeatherApiException(
        'Unexpected weather metrics payload.',
        errorType: WeatherErrorType.unknown,
      );
    }

    if (response.statusCode == 429) {
      debugPrint('$label rate limit (429)');
      throw const WeatherApiException(
        'Weather metrics service rate limit reached.',
        statusCode: 429,
        isRateLimit: true,
        errorType: WeatherErrorType.rateLimit,
      );
    }

    debugPrint('$label error ${response.statusCode}');
    throw WeatherApiException(
      'Weather metrics service unavailable.',
      statusCode: response.statusCode,
      errorType: WeatherErrorType.serverError,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _toInt(dynamic value) {
    if (value is num) return value.round();
    if (value is String) {
      return int.tryParse(value) ?? double.tryParse(value)?.round();
    }
    return null;
  }

  /// Maps wind direction degrees to an 8-sector compass label.
  static String? _compassFromDegrees(double? degrees) {
    if (degrees == null) return null;
    const sectors = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final normalized = ((degrees % 360) + 360) % 360;
    return sectors[(normalized / 45).round() % 8];
  }
}
