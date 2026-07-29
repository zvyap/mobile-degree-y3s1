import 'package:bike_renting_app/features/home/ride_conditions_demo_data.dart';
import 'package:flutter/material.dart';

class RideConditionsPanel extends StatelessWidget {
  const RideConditionsPanel({super.key, required this.data});

  final RideConditionsDemoData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      container: true,
      label:
          'Ride conditions. Current location, ${data.location}. '
          'Current weather, ${data.currentCondition}, '
          '${data.currentTemperature}, ${data.feelsLike}. '
          'Next hour, ${data.nextHourCondition}, '
          '${data.nextHourTemperature}, ${data.nextHourRainChance}. '
          'Humidity ${data.humidity}. Air quality index '
          '${data.airQualityIndex}, ${data.airQualityLabel}. Wind ${data.wind}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ride conditions',
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
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: scheme.tertiary.withValues(alpha: 0.13),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.wb_cloudy_rounded,
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
                              'Current weather',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurface.withValues(alpha: 0.62),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.currentCondition,
                              softWrap: true,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              data.feelsLike,
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
                        data.currentTemperature,
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
                            label: 'Humidity',
                            value: data.humidity,
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          color: scheme.outline.withValues(alpha: 0.58),
                        ),
                        Expanded(
                          child: _ConditionMetric(
                            icon: Icons.air_rounded,
                            label: 'Air quality',
                            value:
                                '${data.airQualityIndex} '
                                '${data.airQualityLabel}',
                          ),
                        ),
                        VerticalDivider(
                          width: 1,
                          color: scheme.outline.withValues(alpha: 0.58),
                        ),
                        Expanded(
                          child: _ConditionMetric(
                            icon: Icons.waves_rounded,
                            label: 'Wind',
                            value: data.wind,
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
                              'Next hour · ${data.nextHourCondition}',
                              softWrap: true,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${data.nextHourTemperature} · '
                              '${data.nextHourRainChance}',
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
                          data.location,
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
                    'Updated ${data.updatedTime} · ${data.dateLabel}',
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
