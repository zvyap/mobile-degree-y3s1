import 'package:flutter/material.dart';

/// Strongly-typed weather condition representing Malaysian MET forecasts.
enum WeatherCondition {
  noRain,
  rain,
  isolatedRain,
  coastalRain,
  inlandRain,
  widespreadRain,
  widespreadInlandRain,
  thunderstorms,
  isolatedThunderstorms,
  coastalThunderstorms,
  inlandThunderstorms,
  widespreadThunderstorms,
  heavyThunderstorms,
  haze,
  unknown;

  /// Parse Malay weather forecast strings from api.data.gov.my into typed enum.
  static WeatherCondition fromApiString(String? text) {
    if (text == null) return WeatherCondition.unknown;
    final normalized = text.trim().toLowerCase();

    if (normalized.contains('tiada hujan') || normalized == 'cerah') {
      return WeatherCondition.noRain;
    }
    if (normalized.contains('jerebu')) {
      return WeatherCondition.haze;
    }
    if (normalized.contains('ribut petir menyeluruh')) {
      return WeatherCondition.heavyThunderstorms;
    }
    if (normalized.contains('ribut petir di kebanyakan tempat')) {
      return WeatherCondition.widespreadThunderstorms;
    }
    if (normalized.contains('ribut petir di beberapa tempat di kawasan pantai')) {
      return WeatherCondition.coastalThunderstorms;
    }
    if (normalized.contains('ribut petir di beberapa tempat di kawasan pedalaman')) {
      return WeatherCondition.inlandThunderstorms;
    }
    if (normalized.contains('ribut petir di beberapa tempat')) {
      return WeatherCondition.isolatedThunderstorms;
    }
    if (normalized.startsWith('ribut petir')) {
      return WeatherCondition.thunderstorms;
    }
    if (normalized.contains('hujan di kebanyakan tempat di kawasan pedalaman')) {
      return WeatherCondition.widespreadInlandRain;
    }
    if (normalized.contains('hujan di kebanyakan tempat')) {
      return WeatherCondition.widespreadRain;
    }
    if (normalized.contains('hujan di beberapa tempat di kawasan pantai')) {
      return WeatherCondition.coastalRain;
    }
    if (normalized.contains('hujan di beberapa tempat di kawasan pedalaman')) {
      return WeatherCondition.inlandRain;
    }
    if (normalized.contains('hujan di beberapa tempat')) {
      return WeatherCondition.isolatedRain;
    }
    if (normalized.startsWith('hujan')) {
      return WeatherCondition.rain;
    }

    return WeatherCondition.unknown;
  }

  /// User-facing English label for the condition.
  String get label => switch (this) {
    WeatherCondition.noRain => 'Clear',
    WeatherCondition.rain => 'Rain',
    WeatherCondition.isolatedRain => 'Scattered Rain',
    WeatherCondition.coastalRain => 'Coastal Rain',
    WeatherCondition.inlandRain => 'Inland Rain',
    WeatherCondition.widespreadRain => 'Widespread Rain',
    WeatherCondition.widespreadInlandRain => 'Widespread Inland Rain',
    WeatherCondition.thunderstorms => 'Thunderstorms',
    WeatherCondition.isolatedThunderstorms => 'Scattered Thunderstorms',
    WeatherCondition.coastalThunderstorms => 'Coastal Thunderstorms',
    WeatherCondition.inlandThunderstorms => 'Inland Thunderstorms',
    WeatherCondition.widespreadThunderstorms => 'Widespread Thunderstorms',
    WeatherCondition.heavyThunderstorms => 'Severe Thunderstorms',
    WeatherCondition.haze => 'Haze',
    WeatherCondition.unknown => 'Partly Cloudy',
  };

  /// Material icon representing this weather condition.
  IconData get iconData => switch (this) {
    WeatherCondition.noRain => Icons.wb_sunny_rounded,
    WeatherCondition.rain ||
    WeatherCondition.isolatedRain ||
    WeatherCondition.coastalRain ||
    WeatherCondition.inlandRain ||
    WeatherCondition.widespreadRain ||
    WeatherCondition.widespreadInlandRain => Icons.water_drop_rounded,
    WeatherCondition.thunderstorms ||
    WeatherCondition.isolatedThunderstorms ||
    WeatherCondition.coastalThunderstorms ||
    WeatherCondition.inlandThunderstorms ||
    WeatherCondition.widespreadThunderstorms ||
    WeatherCondition.heavyThunderstorms => Icons.thunderstorm_rounded,
    WeatherCondition.haze => Icons.blur_on_rounded,
    WeatherCondition.unknown => Icons.wb_cloudy_rounded,
  };

  /// Estimated precipitation probability based on weather severity.
  int get defaultRainChance => switch (this) {
    WeatherCondition.noRain => 10,
    WeatherCondition.haze => 15,
    WeatherCondition.isolatedRain ||
    WeatherCondition.coastalRain ||
    WeatherCondition.inlandRain => 45,
    WeatherCondition.rain => 65,
    WeatherCondition.widespreadRain ||
    WeatherCondition.widespreadInlandRain => 75,
    WeatherCondition.isolatedThunderstorms ||
    WeatherCondition.coastalThunderstorms ||
    WeatherCondition.inlandThunderstorms => 65,
    WeatherCondition.thunderstorms => 80,
    WeatherCondition.widespreadThunderstorms => 85,
    WeatherCondition.heavyThunderstorms => 95,
    WeatherCondition.unknown => 30,
  };

  /// Base humidity percentage estimate for this weather condition.
  int get baseHumidity => switch (this) {
    WeatherCondition.heavyThunderstorms => 92,
    WeatherCondition.widespreadThunderstorms ||
    WeatherCondition.widespreadRain ||
    WeatherCondition.widespreadInlandRain => 88,
    WeatherCondition.thunderstorms || WeatherCondition.rain => 84,
    WeatherCondition.isolatedThunderstorms ||
    WeatherCondition.isolatedRain ||
    WeatherCondition.coastalThunderstorms ||
    WeatherCondition.inlandThunderstorms ||
    WeatherCondition.coastalRain ||
    WeatherCondition.inlandRain => 78,
    WeatherCondition.haze => 58,
    WeatherCondition.noRain => 68,
    WeatherCondition.unknown => 72,
  };

  /// Default Air Quality Index associated with this condition.
  int get baseAqi => switch (this) {
    WeatherCondition.haze => 105,
    WeatherCondition.heavyThunderstorms ||
    WeatherCondition.widespreadThunderstorms ||
    WeatherCondition.widespreadRain ||
    WeatherCondition.widespreadInlandRain ||
    WeatherCondition.rain => 28,
    WeatherCondition.thunderstorms ||
    WeatherCondition.isolatedThunderstorms ||
    WeatherCondition.coastalThunderstorms ||
    WeatherCondition.inlandThunderstorms ||
    WeatherCondition.isolatedRain ||
    WeatherCondition.coastalRain ||
    WeatherCondition.inlandRain => 38,
    WeatherCondition.noRain => 42,
    WeatherCondition.unknown => 42,
  };

  /// Estimated wind speed (km/h) for this condition.
  int get baseWindKmh => switch (this) {
    WeatherCondition.heavyThunderstorms => 28,
    WeatherCondition.widespreadThunderstorms => 22,
    WeatherCondition.thunderstorms ||
    WeatherCondition.coastalThunderstorms ||
    WeatherCondition.inlandThunderstorms => 18,
    WeatherCondition.rain ||
    WeatherCondition.widespreadRain ||
    WeatherCondition.widespreadInlandRain => 14,
    WeatherCondition.isolatedThunderstorms ||
    WeatherCondition.isolatedRain ||
    WeatherCondition.coastalRain ||
    WeatherCondition.inlandRain => 11,
    WeatherCondition.noRain => 8,
    WeatherCondition.haze => 5,
    WeatherCondition.unknown => 9,
  };

  bool get isRaining => switch (this) {
    WeatherCondition.rain ||
    WeatherCondition.isolatedRain ||
    WeatherCondition.coastalRain ||
    WeatherCondition.inlandRain ||
    WeatherCondition.widespreadRain ||
    WeatherCondition.widespreadInlandRain ||
    WeatherCondition.thunderstorms ||
    WeatherCondition.isolatedThunderstorms ||
    WeatherCondition.coastalThunderstorms ||
    WeatherCondition.inlandThunderstorms ||
    WeatherCondition.widespreadThunderstorms ||
    WeatherCondition.heavyThunderstorms => true,
    WeatherCondition.noRain ||
    WeatherCondition.haze ||
    WeatherCondition.unknown => false,
  };

  bool get isSevere => switch (this) {
    WeatherCondition.heavyThunderstorms ||
    WeatherCondition.widespreadThunderstorms => true,
    _ => false,
  };
}

/// Strongly-typed time period for summary forecasts.
enum ForecastPeriod {
  morning,
  afternoon,
  night,
  morningAndAfternoon,
  morningAndNight,
  afternoonAndNight,
  allDay,
  unknown;

  static ForecastPeriod fromApiString(String? text) {
    if (text == null) return ForecastPeriod.unknown;
    final normalized = text.trim().toLowerCase();
    return switch (normalized) {
      'pagi' => ForecastPeriod.morning,
      'petang' => ForecastPeriod.afternoon,
      'malam' => ForecastPeriod.night,
      'pagi dan petang' => ForecastPeriod.morningAndAfternoon,
      'pagi dan malam' => ForecastPeriod.morningAndNight,
      'petang dan malam' => ForecastPeriod.afternoonAndNight,
      'sepanjang hari' => ForecastPeriod.allDay,
      _ => ForecastPeriod.unknown,
    };
  }

  String get label => switch (this) {
    ForecastPeriod.morning => 'Morning',
    ForecastPeriod.afternoon => 'Afternoon',
    ForecastPeriod.night => 'Night',
    ForecastPeriod.morningAndAfternoon => 'Morning & Afternoon',
    ForecastPeriod.morningAndNight => 'Morning & Night',
    ForecastPeriod.afternoonAndNight => 'Afternoon & Night',
    ForecastPeriod.allDay => 'All Day',
    ForecastPeriod.unknown => 'Unknown',
  };
}

/// A single day's forecast entry from api.data.gov.my.
class DailyWeatherForecast {
  const DailyWeatherForecast({
    required this.locationId,
    required this.locationName,
    required this.date,
    required this.morningForecast,
    required this.afternoonForecast,
    required this.nightForecast,
    required this.summaryForecast,
    required this.summaryWhen,
    required this.minTemp,
    required this.maxTemp,
  });

  factory DailyWeatherForecast.fromJson(Map<String, dynamic> json) {
    final location = json['location'] as Map<String, dynamic>? ?? {};
    final rawDate = json['date'] as String?;
    final date = rawDate != null ? DateTime.tryParse(rawDate) : null;

    final minTemp = json['min_temp'];
    final maxTemp = json['max_temp'];

    return DailyWeatherForecast(
      locationId: (location['location_id'] ?? '').toString(),
      locationName: (location['location_name'] ?? '').toString(),
      date: date ?? DateTime.now(),
      morningForecast: WeatherCondition.fromApiString(
        json['morning_forecast'] as String?,
      ),
      afternoonForecast: WeatherCondition.fromApiString(
        json['afternoon_forecast'] as String?,
      ),
      nightForecast: WeatherCondition.fromApiString(
        json['night_forecast'] as String?,
      ),
      summaryForecast: WeatherCondition.fromApiString(
        json['summary_forecast'] as String?,
      ),
      summaryWhen: ForecastPeriod.fromApiString(
        json['summary_when'] as String?,
      ),
      minTemp: minTemp is num ? minTemp.round() : int.tryParse('$minTemp') ?? 24,
      maxTemp: maxTemp is num ? maxTemp.round() : int.tryParse('$maxTemp') ?? 33,
    );
  }

  final String locationId;
  final String locationName;
  final DateTime date;
  final WeatherCondition morningForecast;
  final WeatherCondition afternoonForecast;
  final WeatherCondition nightForecast;
  final WeatherCondition summaryForecast;
  final ForecastPeriod summaryWhen;
  final int minTemp;
  final int maxTemp;

  /// Returns the condition corresponding to a given time of day.
  WeatherCondition conditionAt(DateTime time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 12) {
      return morningForecast != WeatherCondition.unknown
          ? morningForecast
          : summaryForecast;
    } else if (hour >= 12 && hour < 19) {
      return afternoonForecast != WeatherCondition.unknown
          ? afternoonForecast
          : summaryForecast;
    } else {
      return nightForecast != WeatherCondition.unknown
          ? nightForecast
          : summaryForecast;
    }
  }

  /// Returns the condition for the upcoming hour/period.
  WeatherCondition nextPeriodConditionAt(DateTime time) {
    final hour = time.hour;
    if (hour < 11) {
      return afternoonForecast != WeatherCondition.unknown
          ? afternoonForecast
          : summaryForecast;
    } else if (hour < 18) {
      return nightForecast != WeatherCondition.unknown
          ? nightForecast
          : summaryForecast;
    } else {
      return morningForecast != WeatherCondition.unknown
          ? morningForecast
          : summaryForecast;
    }
  }
}

/// Instantaneous ride conditions snapshot prepared for the dashboard.
class WeatherSnapshot {
  const WeatherSnapshot({
    required this.locationName,
    required this.currentCondition,
    required this.currentTemperature,
    required this.feelsLikeTemperature,
    required this.nextHourCondition,
    required this.nextHourTemperature,
    required this.nextHourRainChance,
    required this.humidityPercent,
    required this.airQualityIndex,
    required this.airQualityLabel,
    required this.windSpeedKmh,
    required this.windDirection,
    required this.updatedAt,
    this.dailyForecasts = const [],
  });

  final String locationName;
  final WeatherCondition currentCondition;
  final int currentTemperature;
  final int feelsLikeTemperature;
  final WeatherCondition nextHourCondition;
  final int nextHourTemperature;
  final int nextHourRainChance;
  final int humidityPercent;
  final int airQualityIndex;
  final String airQualityLabel;
  final int windSpeedKmh;
  final String windDirection;
  final DateTime updatedAt;
  final List<DailyWeatherForecast> dailyForecasts;

  String get windFormatted => '$windSpeedKmh km/h $windDirection';
  String get humidityFormatted => '$humidityPercent%';
  String get temperatureFormatted => '$currentTemperature°C';
  String get nextHourTemperatureFormatted => '$nextHourTemperature°C';
  String get rainChanceFormatted => '$nextHourRainChance%';

  /// Fallback snapshot when offline or awaiting initial load.
  factory WeatherSnapshot.fallback({
    String locationName = 'Bukit Mertajam, Penang',
    DateTime? now,
  }) {
    final current = now ?? DateTime.now();
    return WeatherSnapshot(
      locationName: locationName,
      currentCondition: WeatherCondition.isolatedThunderstorms,
      currentTemperature: 30,
      feelsLikeTemperature: 34,
      nextHourCondition: WeatherCondition.thunderstorms,
      nextHourTemperature: 29,
      nextHourRainChance: 65,
      humidityPercent: 78,
      airQualityIndex: 42,
      airQualityLabel: 'Good',
      windSpeedKmh: 9,
      windDirection: 'SW',
      updatedAt: current,
    );
  }
}
