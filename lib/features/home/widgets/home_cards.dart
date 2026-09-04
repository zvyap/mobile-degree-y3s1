import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class NetworkSummary extends StatelessWidget {
  const NetworkSummary({
    super.key,
    this.bikesCount,
    this.openDocksCount,
    this.stationsCount,
    this.isLoading = false,
  });

  final int? bikesCount;
  final int? openDocksCount;
  final int? stationsCount;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final bikesText = bikesCount != null ? '$bikesCount' : (isLoading ? '--' : '0');
    final docksText = openDocksCount != null ? '$openDocksCount' : (isLoading ? '--' : '0');
    final stationsText = stationsCount != null ? '$stationsCount' : (isLoading ? '--' : '0');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.liveNetwork,
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
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _NetworkMetric(
                    value: bikesText,
                    label: context.l10n.bikes,
                    icon: Icons.directions_bike_rounded,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _NetworkMetric(
                    value: docksText,
                    label: context.l10n.openDocks,
                    icon: Icons.local_parking_rounded,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: _NetworkMetric(
                    value: stationsText,
                    label: context.l10n.stations,
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
