import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class StationPreview extends StatelessWidget {
  const StationPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconTile(icon: Icons.map_rounded, color: scheme.tertiary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby stations',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Best return points right now',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.64),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(onPressed: () {}, child: const Text('View map')),
            ],
          ),
          const SizedBox(height: 14),
          const StationRow(
            name: 'Library Station',
            distance: '240m',
            bikes: '18 bikes',
            docks: '7 docks',
          ),
          Divider(color: scheme.outline.withValues(alpha: 0.55)),
          const StationRow(
            name: 'Main Gate',
            distance: '410m',
            bikes: '9 bikes',
            docks: '12 docks',
          ),
        ],
      ),
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
  });

  final String name;
  final String distance;
  final String bikes;
  final String docks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  distance,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ],
            ),
          ),
          _StationChip(label: bikes, icon: Icons.directions_bike_rounded),
          const SizedBox(width: 8),
          _StationChip(label: docks, icon: Icons.local_parking_rounded),
        ],
      ),
    );
  }
}

class _StationChip extends StatelessWidget {
  const _StationChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
