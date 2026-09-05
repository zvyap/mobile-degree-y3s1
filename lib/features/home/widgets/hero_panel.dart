import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class HeroPanel extends StatelessWidget {
  const HeroPanel({
    super.key,
    required this.onScan,
    required this.onFindStation,
    required this.onViewHistory,
    this.availableBikes,
    this.totalStations,
  });

  final VoidCallback onScan;
  final VoidCallback onFindStation;
  final VoidCallback onViewHistory;
  final int? availableBikes;
  final int? totalStations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

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
          context.l10n.bikeAvailability(
            availableBikes ?? 0,
            totalStations ?? 0,
          ),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.68),
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        _HomeActions(
          onScan: onScan,
          onFindStation: onFindStation,
          onViewHistory: onViewHistory,
        ),
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
                // TODO(renting): Load this preview from the active rental plan
                // when the Home module gets repository wiring.
                context.l10n.unlockRate(
                  context.formats.currency(RentingController.defaultUnlockFee),
                  context.formats.currency(
                    RentingController.defaultPerMinuteRate,
                  ),
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
  const _HomeActions({
    required this.onScan,
    required this.onFindStation,
    required this.onViewHistory,
  });

  final VoidCallback onScan;
  final VoidCallback onFindStation;
  final VoidCallback onViewHistory;

  @override
  Widget build(BuildContext context) {
    final usesLargeText = MediaQuery.textScalerOf(context).scale(14) > 18;
    final scan = _HomeAction(
      key: const ValueKey<String>('home-scan'),
      filled: true,
      onPressed: onScan,
      icon: Icons.qr_code_scanner_rounded,
      label: context.l10n.scanBike,
    );
    final station = _HomeAction(
      key: const ValueKey<String>('home-find-station'),
      onPressed: onFindStation,
      icon: Icons.near_me_rounded,
      label: context.l10n.findStation,
    );
    final history = _HomeAction(
      key: const ValueKey<String>('home-view-history'),
      onPressed: onViewHistory,
      icon: Icons.history_rounded,
      label: context.l10n.rideHistory,
    );

    if (usesLargeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          scan,
          const SizedBox(height: 8),
          station,
          const SizedBox(height: 8),
          history,
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: scan),
        const SizedBox(width: 8),
        Expanded(child: station),
        const SizedBox(width: 8),
        Expanded(child: history),
      ],
    );
  }
}

class _HomeAction extends StatelessWidget {
  const _HomeAction({
    super.key,
    required this.onPressed,
    required this.icon,
    required this.label,
    this.filled = false,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(label, maxLines: 2, softWrap: true, textAlign: TextAlign.center),
        ],
      ),
    );

    return SizedBox(
      height: 68,
      child: filled
          ? FilledButton(onPressed: onPressed, child: content)
          : OutlinedButton(onPressed: onPressed, child: content),
    );
  }
}
