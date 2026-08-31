part of '../renting_flow_page.dart';

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final step = _journeyStep(controller.stage);
    final labels = [
      context.l10n.scanStep,
      context.l10n.rideStep,
      context.l10n.returnStep,
      context.l10n.payStep,
    ];

    return Padding(
      key: const ValueKey<String>('rent-journey'),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          for (var index = 0; index < 4; index++) ...[
            Expanded(
              child: _RouteNode(
                label: labels[index],
                icon: const [
                  Icons.qr_code_scanner_rounded,
                  Icons.directions_bike_rounded,
                  Icons.location_on_rounded,
                  Icons.receipt_long_rounded,
                ][index],
                active: index == step,
                complete: index < step,
              ),
            ),
            if (index < 3)
              Expanded(
                child: Container(
                  height: 2,
                  color: index < step
                      ? scheme.secondary
                      : scheme.outline.withValues(alpha: 0.55),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

int _journeyStep(RentalStage stage) {
  return switch (stage) {
    RentalStage.scan || RentalStage.bikeCheck || RentalStage.authorizing => 0,
    RentalStage.unlocking || RentalStage.riding => 1,
    RentalStage.selectingReturn || RentalStage.returning => 2,
    RentalStage.charging || RentalStage.receipt => 3,
  };
}

class _RouteNode extends StatelessWidget {
  const _RouteNode({
    required this.label,
    required this.icon,
    required this.active,
    required this.complete,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = active
        ? scheme.primary
        : complete
        ? scheme.secondary
        : scheme.onSurface.withValues(alpha: 0.45);

    return Semantics(
      label: context.l10n.stepSemantics(label),
      selected: active,
      child: Column(
        children: [
          AnimatedContainer(
            duration: motionDuration(context, 180),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: active || complete ? 0.14 : 0.07),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: active ? 2 : 1),
            ),
            child: Icon(
              complete ? Icons.check_rounded : icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: active || complete
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
