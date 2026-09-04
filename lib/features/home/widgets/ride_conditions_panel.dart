import 'dart:io' show Platform;
import 'package:bike_renting_app/features/weather/user_location_service.dart';
import 'package:bike_renting_app/features/weather/weather_api_service.dart';
import 'package:bike_renting_app/features/weather/weather_models.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: scheme.tertiary.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          snapshot.currentCondition.iconData,
                          color: scheme.tertiary,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
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
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _ConditionMetric(
                            icon: Icons.water_drop_outlined,
                            label: context.l10n.humidity,
                            value: humidity,
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          color: scheme.outline.withValues(alpha: 0.58),
                        ),
                        Expanded(
                          child: _ConditionMetric(
                            icon: Icons.air_rounded,
                            label: context.l10n.airQuality,
                            value: '$airQualityIndex $airQualityLabel',
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          color: scheme.outline.withValues(alpha: 0.58),
                        ),
                        Expanded(
                          child: _ConditionMetric(
                            icon: Icons.waves_rounded,
                            label: context.l10n.wind,
                            value: wind,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.schedule_rounded,
                          size: 17,
                          color: scheme.primary,
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
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              context.l10n.weatherValues(
                                nextHourTemperature,
                                nextHourRainChance,
                              ),
                              softWrap: true,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.68),
                                fontWeight: FontWeight.w700,
                              ),
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
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7),
      child: Column(
        children: [
          Icon(icon, size: 16, color: scheme.primary),
          const SizedBox(height: 3),
          Text(
            value,
            textAlign: TextAlign.center,
            softWrap: true,
            style: theme.textTheme.labelMedium?.copyWith(
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
