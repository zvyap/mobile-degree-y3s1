import 'dart:io' show Platform;
import 'package:bike_renting_app/features/weather/user_location_service.dart';
import 'package:bike_renting_app/features/weather/weather_api_service.dart';
import 'package:bike_renting_app/features/weather/weather_models.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Semantic color palette for weather, air quality, humidity, and temperature.
class WeatherColorPalette {
  const WeatherColorPalette(this.isDark);

  final bool isDark;

  Color getConditionColor(WeatherCondition condition) {
    if (isDark) {
      return switch (condition) {
        WeatherCondition.noRain => const Color(0xFF4ADE80), // clear emerald green
        WeatherCondition.haze => const Color(0xFFFACC15), // haze yellow
        WeatherCondition.rain ||
        WeatherCondition.isolatedRain ||
        WeatherCondition.coastalRain ||
        WeatherCondition.inlandRain ||
        WeatherCondition.widespreadRain ||
        WeatherCondition.widespreadInlandRain => const Color(0xFF38BDF8), // sky rain blue
        WeatherCondition.thunderstorms ||
        WeatherCondition.isolatedThunderstorms ||
        WeatherCondition.coastalThunderstorms ||
        WeatherCondition.inlandThunderstorms ||
        WeatherCondition.widespreadThunderstorms => const Color(0xFFF87171), // thunderstorm coral
        WeatherCondition.heavyThunderstorms => const Color(0xFFEF4444), // severe red
        WeatherCondition.unknown => const Color(0xFF94A3B8), // slate
      };
    } else {
      return switch (condition) {
        WeatherCondition.noRain => const Color(0xFF16A34A), // clear green
        WeatherCondition.haze => const Color(0xFFCA8A04), // haze yellow
        WeatherCondition.rain ||
        WeatherCondition.isolatedRain ||
        WeatherCondition.coastalRain ||
        WeatherCondition.inlandRain ||
        WeatherCondition.widespreadRain ||
        WeatherCondition.widespreadInlandRain => const Color(0xFF0284C7), // ocean blue
        WeatherCondition.thunderstorms ||
        WeatherCondition.isolatedThunderstorms ||
        WeatherCondition.coastalThunderstorms ||
        WeatherCondition.inlandThunderstorms ||
        WeatherCondition.widespreadThunderstorms => const Color(0xFFDC2626), // crimson
        WeatherCondition.heavyThunderstorms => const Color(0xFFB91C1C), // deep red
        WeatherCondition.unknown => const Color(0xFF475569), // slate
      };
    }
  }

  Color getTemperatureColor(int temp) {
    if (isDark) {
      if (temp >= 33) return const Color(0xFFFB7185); // hot rose
      if (temp >= 28) return const Color(0xFFFB923C); // warm orange
      if (temp >= 23) return const Color(0xFF34D399); // comfortable emerald
      return const Color(0xFF38BDF8); // cool cyan
    } else {
      if (temp >= 33) return const Color(0xFFE11D48); // hot rose
      if (temp >= 28) return const Color(0xFFEA580C); // warm orange
      if (temp >= 23) return const Color(0xFF059669); // comfortable emerald
      return const Color(0xFF0284C7); // cool cyan
    }
  }

  Color getHumidityColor(int humidity) {
    if (isDark) {
      if (humidity > 75) return const Color(0xFF38BDF8); // humid blue
      if (humidity >= 45) return const Color(0xFF2DD4BF); // comfortable teal
      return const Color(0xFFFACC15); // dry yellow
    } else {
      if (humidity > 75) return const Color(0xFF0284C7); // humid blue
      if (humidity >= 45) return const Color(0xFF0D9488); // comfortable teal
      return const Color(0xFFCA8A04); // dry yellow
    }
  }

  Color getAqiColor(int aqi) {
    if (isDark) {
      if (aqi <= 50) return const Color(0xFF4ADE80); // good green
      if (aqi <= 100) return const Color(0xFFFACC15); // moderate yellow
      if (aqi <= 200) return const Color(0xFFF87171); // unhealthy orange-red
      if (aqi <= 300) return const Color(0xFFC084FC); // very unhealthy purple
      return const Color(0xFFFDA4AF); // hazardous maroon
    } else {
      if (aqi <= 50) return const Color(0xFF16A34A); // good green
      if (aqi <= 100) return const Color(0xFFCA8A04); // moderate yellow
      if (aqi <= 200) return const Color(0xFFDC2626); // unhealthy red
      if (aqi <= 300) return const Color(0xFF7C3AED); // very unhealthy purple
      return const Color(0xFF991B1B); // hazardous maroon
    }
  }

  Color getWindColor(int speedKmh) {
    if (isDark) {
      if (speedKmh >= 25) return const Color(0xFFFB923C); // strong wind orange
      if (speedKmh >= 10) return const Color(0xFF60A5FA); // moderate blue
      return const Color(0xFF2DD4BF); // gentle breeze teal
    } else {
      if (speedKmh >= 25) return const Color(0xFFEA580C); // strong wind orange
      if (speedKmh >= 10) return const Color(0xFF2563EB); // moderate blue
      return const Color(0xFF0D9488); // gentle breeze teal
    }
  }

  Color getRainChanceColor(int percent) {
    if (isDark) {
      if (percent >= 60) return const Color(0xFF38BDF8);
      if (percent >= 30) return const Color(0xFF2DD4BF);
      return const Color(0xFF94A3B8);
    } else {
      if (percent >= 60) return const Color(0xFF0284C7);
      if (percent >= 30) return const Color(0xFF0D9488);
      return const Color(0xFF64748B);
    }
  }
}

class RideConditionsPanel extends StatefulWidget {
  const RideConditionsPanel({
    super.key,
    this.weatherService,
    this.locationService,
    this.initialSnapshot,
    this.autoFetch,
  });

  final WeatherApiService? weatherService;
  final UserLocationService? locationService;
  final WeatherSnapshot? initialSnapshot;
  final bool? autoFetch;

  /// Cached snapshot across widget instances to prevent auto-refreshing when
  /// navigating away and back to the Home page.
  static WeatherSnapshot? cachedSnapshot;

  /// Clears the cached snapshot (useful in testing or full session reset).
  static void resetCache() {
    cachedSnapshot = null;
  }

  @override
  State<RideConditionsPanel> createState() => RideConditionsPanelState();
}

/// Structured user-facing error details for the ride conditions panel.
class WeatherPanelError {
  const WeatherPanelError({
    required this.title,
    required this.message,
    required this.icon,
    this.isRateLimit = false,
  });

  final String title;
  final String message;
  final IconData icon;
  final bool isRateLimit;

  factory WeatherPanelError.from(Object error, AppLocalizations l10n) {
    if (error is WeatherApiException) {
      switch (error.errorType) {
        case WeatherErrorType.network:
          return WeatherPanelError(
            title: l10n.weatherConnectionFailedTitle,
            message: l10n.weatherConnectionFailedBody,
            icon: Icons.wifi_off_rounded,
          );
        case WeatherErrorType.timeout:
          return WeatherPanelError(
            title: l10n.weatherTimeoutTitle,
            message: l10n.weatherTimeoutBody,
            icon: Icons.timer_outlined,
          );
        case WeatherErrorType.rateLimit:
          return WeatherPanelError(
            title: l10n.weatherRateLimitTitle,
            message: l10n.weatherRateLimitBody,
            icon: Icons.hourglass_top_rounded,
            isRateLimit: true,
          );
        case WeatherErrorType.locationUnavailable:
          return WeatherPanelError(
            title: l10n.weatherLocationTitle,
            message: l10n.weatherLocationBody,
            icon: Icons.location_off_rounded,
          );
        case WeatherErrorType.outsideMalaysia:
          return WeatherPanelError(
            title: l10n.weatherOutsideMalaysiaTitle,
            message: l10n.weatherOutsideMalaysiaBody,
            icon: Icons.location_off_rounded,
          );
        case WeatherErrorType.serverError:
          return WeatherPanelError(
            title: l10n.weatherServiceTitle,
            message: l10n.weatherServiceBody,
            icon: Icons.cloud_off_rounded,
          );
        case WeatherErrorType.notFound:
          return WeatherPanelError(
            title: l10n.weatherNotFoundTitle,
            message: l10n.weatherNotFoundBody,
            icon: Icons.cloud_off_rounded,
          );
        case WeatherErrorType.unknown:
          break;
      }

      if (error.isRateLimit || error.statusCode == 429) {
        return WeatherPanelError(
          title: l10n.weatherRateLimitTitle,
          message: l10n.weatherRateLimitBody,
          icon: Icons.hourglass_top_rounded,
          isRateLimit: true,
        );
      }
    }

    // Inspect string for raw technical indicators
    final str = error.toString().toLowerCase();
    if (str.contains('socketexception') ||
        str.contains('failed host lookup') ||
        str.contains('clientexception') ||
        str.contains('network is unreachable') ||
        str.contains('connection refused') ||
        str.contains('no address associated with hostname') ||
        str.contains('handshakeexception') ||
        str.contains('network error')) {
      return WeatherPanelError(
        title: l10n.weatherConnectionFailedTitle,
        message: l10n.weatherConnectionFailedBody,
        icon: Icons.wifi_off_rounded,
      );
    }

    if (str.contains('timeoutexception') || str.contains('timed out')) {
      return WeatherPanelError(
        title: l10n.weatherTimeoutTitle,
        message: l10n.weatherTimeoutBody,
        icon: Icons.timer_outlined,
      );
    }

    if (str.contains('429') || str.contains('rate limit')) {
      return WeatherPanelError(
        title: l10n.weatherRateLimitTitle,
        message: l10n.weatherRateLimitBody,
        icon: Icons.hourglass_top_rounded,
        isRateLimit: true,
      );
    }

    if (str.contains('gps') ||
        str.contains('permission') ||
        str.contains('location access')) {
      return WeatherPanelError(
        title: l10n.weatherLocationTitle,
        message: l10n.weatherLocationBody,
        icon: Icons.location_off_rounded,
      );
    }

    if (str.contains('outside malaysia')) {
      return WeatherPanelError(
        title: l10n.weatherOutsideMalaysiaTitle,
        message: l10n.weatherOutsideMalaysiaBody,
        icon: Icons.location_off_rounded,
      );
    }

    return WeatherPanelError(
      title: l10n.weatherGenericTitle,
      message: l10n.weatherGenericBody,
      icon: Icons.cloud_off_rounded,
    );
  }
}

class RideConditionsPanelState extends State<RideConditionsPanel> {
  late final WeatherApiService _weatherService;
  late final UserLocationService _locationService;
  late final bool _isTest;

  WeatherSnapshot? _snapshot;
  bool _isLoading = false;
  WeatherPanelError? _error;

  @visibleForTesting
  String? get errorMessage => _error?.message;
  @visibleForTesting
  bool get isRateLimit => _error?.isRateLimit ?? false;

  /// Trigger a live refresh of weather conditions.
  Future<void> refresh({bool forceRefresh = true}) =>
      _loadWeather(forceRefresh: forceRefresh);

  @override
  void initState() {
    super.initState();
    _weatherService = widget.weatherService ?? WeatherApiService.shared;
    _locationService = widget.locationService ?? UserLocationService();
    _isTest = Platform.environment.containsKey('FLUTTER_TEST');

    final shouldAutoFetch = widget.autoFetch ?? !_isTest;

    if (widget.initialSnapshot != null) {
      _snapshot = widget.initialSnapshot;
      RideConditionsPanel.cachedSnapshot = widget.initialSnapshot;
    } else if (RideConditionsPanel.cachedSnapshot != null) {
      _snapshot = RideConditionsPanel.cachedSnapshot;
      _isLoading = false;
    } else {
      _snapshot = null;
      if (shouldAutoFetch) {
        _isLoading = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _loadWeather();
          }
        });
      }
    }
  }

  Future<void> _loadWeather({bool forceRefresh = false}) async {
    if (_isLoading && _snapshot != null) return;
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final userLocation = await _locationService.getCurrentUserLocation();
      final snapshot = await _weatherService.getRideConditions(
        userLocation,
        forceRefresh: forceRefresh,
      );
      RideConditionsPanel.cachedSnapshot = snapshot;
      if (mounted) {
        setState(() {
          _snapshot = snapshot;
          _error = null;
        });
      }
    } catch (e) {
      debugPrint('RideConditionsPanel load error: $e');
      if (mounted) {
        setState(() {
          _snapshot = null;
          _error = WeatherPanelError.from(e, context.l10n);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final palette = WeatherColorPalette(isDark);

    final snapshot = _snapshot;
    if (snapshot == null) {
      if (_error != null && !_isLoading) {
        final error = _error!;
        return Semantics(
          container: true,
          label: error.isRateLimit
              ? context.l10n.rideConditionsRateLimitSemantics
              : context.l10n.rideConditionsErrorSemantics(
                  error.title,
                  error.message,
                ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.rideConditions,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              DecoratedBox(
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.76),
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          error.icon,
                          color: error.isRateLimit ? scheme.error : scheme.onSurfaceVariant,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.title,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: error.isRateLimit ? scheme.error : scheme.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          error.message,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.75),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          key: const ValueKey<String>('weather-retry-button'),
                          onPressed: () => refresh(forceRefresh: true),
                          icon: const Icon(Icons.refresh_rounded, size: 18),
                          label: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Semantics(
        container: true,
        label: context.l10n.rideConditions,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.rideConditions,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.symmetric(
                  horizontal: BorderSide(
                    color: scheme.outline.withValues(alpha: 0.76),
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 160,
                child: Center(
                  child: CircularProgressIndicator(
                    key: const ValueKey<String>('ride-conditions-loader'),
                    value: _isTest ? 0.0 : null,
                    color: scheme.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    final location = snapshot.locationName;
    final currentCondition = snapshot.currentCondition.label;
    final currentTemperature = snapshot.temperatureFormatted;
    final feelsLike = snapshot.feelsLikeTemperature != null
        ? context.l10n.feelsLike('${snapshot.feelsLikeTemperature}°C')
        : '–';
    final nextHourCondition = snapshot.nextHourCondition.label;
    final nextHourTemperature = snapshot.nextHourTemperatureFormatted;
    final nextHourRainChance = snapshot.nextHourRainChance != null
        ? context.l10n.rainChance(snapshot.nextHourRainChance!)
        : '–';
    final humidity = snapshot.humidityFormatted;
    final airQualityIndex = snapshot.airQualityIndex?.toString() ?? '–';
    final airQualityLabel = snapshot.airQualityIndex != null
        ? _aqiLabel(context.l10n, snapshot.airQualityIndex!)
        : '–';
    final wind = snapshot.windFormatted;
    final updatedAt = snapshot.updatedAt;
    final date = snapshot.updatedAt;

    // Semantic colors; measured-metric colors only apply when the value exists.
    final conditionColor = palette.getConditionColor(snapshot.currentCondition);
    final tempColor = snapshot.currentTemperature != null
        ? palette.getTemperatureColor(snapshot.currentTemperature!)
        : scheme.onSurfaceVariant;
    final humidityColor = snapshot.humidityPercent != null
        ? palette.getHumidityColor(snapshot.humidityPercent!)
        : scheme.onSurfaceVariant;
    final aqiColor = snapshot.airQualityIndex != null
        ? palette.getAqiColor(snapshot.airQualityIndex!)
        : scheme.onSurfaceVariant;
    final windColor = snapshot.windSpeedKmh != null
        ? palette.getWindColor(snapshot.windSpeedKmh!)
        : scheme.onSurfaceVariant;
    final nextHourConditionColor = palette.getConditionColor(snapshot.nextHourCondition);
    final nextHourTempColor = snapshot.nextHourTemperature != null
        ? palette.getTemperatureColor(snapshot.nextHourTemperature!)
        : scheme.onSurfaceVariant;
    final nextHourRainColor = snapshot.nextHourRainChance != null
        ? palette.getRainChanceColor(snapshot.nextHourRainChance!)
        : scheme.onSurfaceVariant;

    // Measured metric tiles; hidden entirely when Open-Meteo is unavailable.
    final metricTiles = <Widget>[
      if (snapshot.humidityPercent != null)
        _ConditionMetric(
          icon: Icons.water_drop_outlined,
          label: context.l10n.humidity,
          value: humidity,
          iconColor: humidityColor,
          valueColor: humidityColor,
          backgroundColor: humidityColor.withValues(
            alpha: isDark ? 0.12 : 0.08,
          ),
        ),
      if (snapshot.airQualityIndex != null)
        _ConditionMetric(
          icon: Icons.air_rounded,
          label: context.l10n.airQuality,
          value: '$airQualityIndex $airQualityLabel',
          iconColor: aqiColor,
          valueColor: aqiColor,
          backgroundColor: aqiColor.withValues(
            alpha: isDark ? 0.14 : 0.09,
          ),
        ),
      if (snapshot.windSpeedKmh != null)
        _ConditionMetric(
          icon: Icons.waves_rounded,
          label: context.l10n.wind,
          value: wind,
          iconColor: windColor,
          valueColor: windColor,
          backgroundColor: windColor.withValues(
            alpha: isDark ? 0.12 : 0.08,
          ),
        ),
    ];

    return Semantics(
      container: true,
      label: context.l10n.rideConditionsSemantics(
        location,
        currentCondition,
        currentTemperature,
        feelsLike,
        nextHourCondition,
        nextHourTemperature,
        nextHourRainChance,
        humidity,
        airQualityIndex,
        airQualityLabel,
        wind,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.rideConditions,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: scheme.outline.withValues(alpha: 0.76),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: conditionColor.withValues(alpha: isDark ? 0.20 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: conditionColor.withValues(alpha: isDark ? 0.35 : 0.28),
                          ),
                        ),
                        child: Icon(
                          snapshot.currentCondition.iconData,
                          color: conditionColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.currentWeather,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: isDark ? 0.62 : 0.70),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentCondition,
                              softWrap: true,
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: conditionColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (snapshot.feelsLikeTemperature != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                feelsLike,
                                softWrap: true,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: isDark ? 0.64 : 0.70),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (snapshot.currentTemperature != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          currentTemperature,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: tempColor,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (metricTiles.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var index = 0; index < metricTiles.length; index++) ...[
                            if (index > 0) const SizedBox(width: 6),
                            Expanded(child: metricTiles[index]),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.schedule_rounded,
                          size: 17,
                          color: nextHourConditionColor,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.nextHour(nextHourCondition),
                              softWrap: true,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: nextHourConditionColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (snapshot.nextHourTemperature != null ||
                                snapshot.nextHourRainChance != null) ...[
                              const SizedBox(height: 2),
                              Text.rich(
                                TextSpan(
                                  children: [
                                    if (snapshot.nextHourTemperature != null)
                                      TextSpan(
                                        text: nextHourTemperature,
                                        style: TextStyle(
                                          color: nextHourTempColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    if (snapshot.nextHourTemperature != null &&
                                        snapshot.nextHourRainChance != null)
                                      TextSpan(
                                        text: ' · ',
                                        style: TextStyle(
                                          color: scheme.onSurface.withValues(
                                            alpha: isDark ? 0.50 : 0.58,
                                          ),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    if (snapshot.nextHourRainChance != null)
                                      TextSpan(
                                        text: nextHourRainChance,
                                        style: TextStyle(
                                          color: nextHourRainColor,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                  ],
                                ),
                                softWrap: true,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.my_location_rounded,
                        size: 16,
                        color: scheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          softWrap: true,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    context.l10n.weatherUpdated(
                      context.formats.time(updatedAt),
                      context.formats.date(date),
                    ),
                    softWrap: true,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: scheme.onSurface.withValues(alpha: isDark ? 0.58 : 0.68),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Maps a measured US AQI value to its localized band label.
String _aqiLabel(AppLocalizations l10n, int aqi) {
  if (aqi <= 50) return l10n.good;
  if (aqi <= 100) return l10n.aqiModerate;
  if (aqi <= 200) return l10n.aqiUnhealthy;
  if (aqi <= 300) return l10n.aqiVeryUnhealthy;
  return l10n.aqiHazardous;
}

class _ConditionMetric extends StatelessWidget {
  const _ConditionMetric({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.iconColor,
    this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final Color? iconColor;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final borderColor = (iconColor ?? scheme.primary).withValues(
      alpha: isDark ? 0.22 : 0.18,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Column(
        children: [
          Icon(icon, size: 16, color: iconColor ?? scheme.primary),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            softWrap: true,
            style: theme.textTheme.labelMedium?.copyWith(
              color: valueColor ?? scheme.onSurface,
              fontWeight: FontWeight.w900,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: isDark ? 0.62 : 0.72),
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
