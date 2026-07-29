import 'package:flutter/material.dart';

class NetworkSummary extends StatelessWidget {
  const NetworkSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live network',
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
          child: const IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _NetworkMetric(
                    value: '128',
                    label: 'Bikes',
                    icon: Icons.directions_bike_rounded,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _NetworkMetric(
                    value: '73',
                    label: 'Open docks',
                    icon: Icons.local_parking_rounded,
                  ),
                ),
                VerticalDivider(width: 1),
                Expanded(
                  child: _NetworkMetric(
                    value: '9',
                    label: 'Stations',
                    icon: Icons.map_rounded,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NetworkMetric extends StatelessWidget {
  const _NetworkMetric({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: scheme.primary),
          const SizedBox(height: 3),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            textAlign: TextAlign.center,
            softWrap: true,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.66),
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
