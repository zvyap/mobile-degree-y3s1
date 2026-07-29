import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class HeroPanel extends StatelessWidget {
  const HeroPanel({
    super.key,
    required this.onScan,
    required this.onFindStation,
  });

  final VoidCallback onScan;
  final VoidCallback onFindStation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    // TODO: Load bike and station availability from their services.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.goodAfternoon,
          style: theme.textTheme.labelSmall?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.readyToRide,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          context.l10n.bikeAvailability(128, 9),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.68),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        _HomeActions(onScan: onScan, onFindStation: onFindStation),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.payments_outlined,
              size: 17,
              color: scheme.onSurface.withValues(alpha: 0.62),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                context.l10n.unlockRate(
                  context.formats.currency(RentingController.unlockFee),
                  context.formats.currency(RentingController.perMinuteRate),
                ),
                softWrap: true,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.62),
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HomeActions extends StatelessWidget {
  const _HomeActions({required this.onScan, required this.onFindStation});

  final VoidCallback onScan;
  final VoidCallback onFindStation;

  @override
  Widget build(BuildContext context) {
    final usesLargeText = MediaQuery.textScalerOf(context).scale(14) > 18;
    final scan = FilledButton.icon(
      key: const ValueKey<String>('home-scan'),
      onPressed: onScan,
      icon: const Icon(Icons.qr_code_scanner_rounded, size: 20),
      label: Text(context.l10n.scanBike),
    );
    final station = OutlinedButton.icon(
      key: const ValueKey<String>('home-find-station'),
      onPressed: onFindStation,
      icon: const Icon(Icons.near_me_rounded, size: 20),
      label: Text(context.l10n.findStation),
    );

    if (usesLargeText) {
      return Wrap(spacing: 8, runSpacing: 8, children: [scan, station]);
    }

    return Row(
      children: [
        Expanded(child: scan),
        const SizedBox(width: 8),
        Expanded(child: station),
      ],
    );
  }
}
