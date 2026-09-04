import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class StationPreview extends StatelessWidget {
  const StationPreview({
    super.key,
    required this.onViewAll,
    this.stations = const [],
    this.isLoading = false,
  });

  final VoidCallback onViewAll;
  final List<ReturnStation> stations;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final previewStations = stations.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.nearYou,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(
              key: const ValueKey<String>('home-view-stations'),
              onPressed: onViewAll,
              child: Text(context.l10n.viewAll),
            ),
          ],
        ),
        Divider(height: 1, color: scheme.outline.withValues(alpha: 0.76)),
        if (isLoading && stations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: scheme.primary,
                ),
              ),
            ),
          )
        else if (stations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Text(
              context.l10n.returnStationUnavailable,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
          )
        else
          ...previewStations.asMap().entries.map((entry) {
            final index = entry.key;
            final station = entry.value;
            final availability = station.capacity > 0
                ? (station.availableBikes / station.capacity).clamp(0.0, 1.0)
                : 0.0;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (index > 0)
                  Divider(height: 1, color: scheme.outline.withValues(alpha: 0.58)),
                StationRow(
                  name: station.name,
                  distance: context.l10n.stationDistance(station.distanceMeters),
                  bikes: context.l10n.bikeCount(station.availableBikes),
                  docks: context.l10n.dockCount(station.availableDocks),
                  availability: availability,
                ),
              ],
            );
          }),
      ],
    );
  }
}

class StationRow extends StatelessWidget {
  const StationRow({
    super.key,
    required this.name,
    required this.distance,
    required this.bikes,
    required this.docks,
    required this.availability,
  });

  final String name;
  final String distance;
  final String bikes;
  final String docks;
  final double availability;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final usesLargeText = MediaQuery.textScalerOf(context).scale(12) > 15;
    final stationDetails = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          softWrap: true,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          distance,
          softWrap: true,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.62),
          ),
        ),
      ],
    );
    final stationFacts = Wrap(
      alignment: usesLargeText ? WrapAlignment.start : WrapAlignment.end,
      spacing: 10,
      runSpacing: 4,
      children: [
        _StationFact(label: bikes, icon: Icons.directions_bike_rounded),
        _StationFact(label: docks, icon: Icons.local_parking_rounded),
      ],
    );

    return Semantics(
      container: true,
      label: '$name, $distance, $bikes, $docks',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              height: 42,
              decoration: BoxDecoration(
                color: Color.lerp(
                  scheme.tertiary,
                  scheme.secondary,
                  availability,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 10),
            if (usesLargeText)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    stationDetails,
                    const SizedBox(height: 7),
                    stationFacts,
                  ],
                ),
              )
            else ...[
              Expanded(child: stationDetails),
              const SizedBox(width: 10),
              Flexible(child: stationFacts),
            ],
          ],
        ),
      ),
    );
  }
}

class _StationFact extends StatelessWidget {
  const _StationFact({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: scheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          softWrap: true,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
