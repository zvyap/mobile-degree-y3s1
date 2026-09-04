import 'dart:io' show Platform;
import 'package:bike_renting_app/features/weather/user_location_service.dart';
import 'package:bike_renting_app/features/weather/weather_api_service.dart';
import 'package:bike_renting_app/features/weather/weather_models.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Semantic color palette for weather, air quality, humidity, and temperature.
class WeatherColorPalette {
  const WeatherColorPalette(this.isDark);

  final bool isDark;

  Color getConditionColor(WeatherCondition condition) {
    if (isDark) {
      return switch (condition) {
        WeatherCondition.noRain => const Color(0xFFFBBF24), // warm sun gold
        WeatherCondition.haze => const Color(0xFFFB923C), // atmospheric orange
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
        WeatherCondition.noRain => const Color(0xFFB45309), // dark amber
        WeatherCondition.haze => const Color(0xFFC2410C), // burnt orange
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
      if (temp >= 28) return const Color(0xFFD97706); // warm amber
      if (temp >= 23) return const Color(0xFF059669); // comfortable emerald
      return const Color(0xFF0284C7); // cool cyan
    }
  }

  Color getHumidityColor(int humidity) {
    if (isDark) {
      if (humidity > 75) return const Color(0xFF38BDF8); // humid blue
      if (humidity >= 45) return const Color(0xFF2DD4BF); // comfortable teal
      return const Color(0xFFFBBF24); // dry amber
    } else {
      if (humidity > 75) return const Color(0xFF0284C7); // humid blue
      if (humidity >= 45) return const Color(0xFF0D9488); // comfortable teal
      return const Color(0xFFB45309); // dry amber
    }
  }

  Color getAqiColor(int aqi) {
    if (isDark) {
      if (aqi <= 50) return const Color(0xFF4ADE80); // good green
      if (aqi <= 100) return const Color(0xFFFBBF24); // moderate yellow
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
      if (speedKmh >= 25) return const Color(0xFFD97706); // strong wind orange
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

  @override
  State<RideConditionsPanel> createState() => RideConditionsPanelState();
}

class RideConditionsPanelState extends State<RideConditionsPanel> {
  late final WeatherApiService _weatherService;
  late final UserLocationService _locationService;

  WeatherSnapshot? _snapshot;
  bool _isLoading = false;

  /// Trigger a live refresh of weather conditions.
  Future<void> refresh({bool forceRefresh = true}) =>
      _loadWeather(forceRefresh: forceRefresh);

  @override
  void initState() {
    super.initState();
    _weatherService = widget.weatherService ?? WeatherApiService();
    _locationService = widget.locationService ?? UserLocationService();

    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    final shouldAutoFetch = widget.autoFetch ?? !isTest;

    if (widget.initialSnapshot != null) {
      _snapshot = widget.initialSnapshot;
    } else {
      _snapshot = WeatherSnapshot.fallback();
      if (shouldAutoFetch) {
        _loadWeather();
      }
    }
  }

  Future<void> _loadWeather({bool forceRefresh = false}) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      final userLocation = await _locationService.getCurrentUserLocation();
      final snapshot = await _weatherService.getRideConditions(
        userLocation,
        forceRefresh: forceRefresh,
      );
      if (mounted) {
        setState(() {
          _snapshot = snapshot;
        });
      }
    } catch (e) {
      debugPrint('RideConditionsPanel load error: $e');
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

    final snapshot = _snapshot ?? WeatherSnapshot.fallback();
    final location = snapshot.locationName;
    final currentCondition = snapshot.currentCondition.label;
    final currentTemperature = snapshot.temperatureFormatted;
    final feelsLike = context.l10n.feelsLike('${snapshot.feelsLikeTemperature}°C');
    final nextHourCondition = snapshot.nextHourCondition.label;
    final nextHourTemperature = snapshot.nextHourTemperatureFormatted;
    final nextHourRainChance = context.l10n.rainChance(snapshot.nextHourRainChance);
    final humidity = snapshot.humidityFormatted;
    final airQualityIndex = '${snapshot.airQualityIndex}';
    final airQualityLabel = snapshot.airQualityLabel;
    final wind = snapshot.windFormatted;
    final updatedAt = snapshot.updatedAt;
    final date = snapshot.updatedAt;

    // Semantic colors
    final conditionColor = palette.getConditionColor(snapshot.currentCondition);
    final tempColor = palette.getTemperatureColor(snapshot.currentTemperature);
    final humidityColor = palette.getHumidityColor(snapshot.humidityPercent);
    final aqiColor = palette.getAqiColor(snapshot.airQualityIndex);
    final windColor = palette.getWindColor(snapshot.windSpeedKmh);
    final nextHourConditionColor = palette.getConditionColor(snapshot.nextHourCondition);
    final nextHourTempColor = palette.getTemperatureColor(snapshot.nextHourTemperature);
    final nextHourRainColor = palette.getRainChanceColor(snapshot.nextHourRainChance);

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  context.l10n.rideConditions,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                iconSize: 18,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                icon: _isLoading
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: scheme.primary,
                        ),
                      )
                    : Icon(Icons.refresh_rounded, color: scheme.primary),
                tooltip: 'Refresh ride weather conditions',
                onPressed: _isLoading ? null : () => _loadWeather(forceRefresh: true),
              ),
            ],
          ),
          const SizedBox(height: 4),
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
                            color: conditionColor.withValues(alpha: 0.35),
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
                                color: scheme.onSurface.withValues(alpha: 0.62),
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
                            const SizedBox(height: 2),
                            Text(
                              feelsLike,
                              softWrap: true,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.64),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentTemperature,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: tempColor,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _ConditionMetric(
                            icon: Icons.water_drop_outlined,
                            label: context.l10n.humidity,
                            value: humidity,
                            iconColor: humidityColor,
                            valueColor: humidityColor,
                            backgroundColor: humidityColor.withValues(
                              alpha: isDark ? 0.12 : 0.07,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _ConditionMetric(
                            icon: Icons.air_rounded,
                            label: context.l10n.airQuality,
                            value: '$airQualityIndex $airQualityLabel',
                            iconColor: aqiColor,
                            valueColor: aqiColor,
                            backgroundColor: aqiColor.withValues(
                              alpha: isDark ? 0.14 : 0.08,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: _ConditionMetric(
                            icon: Icons.waves_rounded,
                            label: context.l10n.wind,
                            value: wind,
                            iconColor: windColor,
                            valueColor: windColor,
                            backgroundColor: windColor.withValues(
                              alpha: isDark ? 0.12 : 0.07,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                            Text.rich(
                              TextSpan(
                                text: 'Next hour · ',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.75),
                                  fontWeight: FontWeight.w600,
                                ),
                                children: [
                                  TextSpan(
                                    text: nextHourCondition,
                                    style: TextStyle(
                                      color: nextHourConditionColor,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              softWrap: true,
                            ),
                            const SizedBox(height: 2),
                            Text.rich(
                              TextSpan(
                                text: nextHourTemperature,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: nextHourTempColor,
                                  fontWeight: FontWeight.w800,
                                ),
                                children: [
                                  TextSpan(
                                    text: ' · ',
                                    style: TextStyle(
                                      color: scheme.onSurface.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
                      color: scheme.onSurface.withValues(alpha: 0.58),
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

    return Container(
      decoration: backgroundColor != null
          ? BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(10),
            )
          : null,
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
              color: scheme.onSurface.withValues(alpha: 0.62),
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
