part of '../renting_flow_page.dart';

class _ReturnStage extends StatelessWidget {
  const _ReturnStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _StageTitle(
            icon: Icons.keyboard_double_arrow_down_rounded,
            title: context.l10n.secureBike,
            subtitle: context.l10n.secureBikeDescription,
          ),
          const SizedBox(height: 18),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: controller.isBusy
                ? Padding(
                    padding: const EdgeInsets.all(28),
                    child: CircularProgressIndicator(color: scheme.secondary),
                  )
                : Icon(
                    Icons.pedal_bike_rounded,
                    size: 48,
                    color: scheme.secondary,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            _stationName(context.l10n, controller.selectedStation!),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            context.l10n.docksAvailable(
              controller.selectedStation!.availableDocks,
            ),
          ),
          if (controller.error != null) ...[
            const SizedBox(height: 18),
            _ErrorPanel(message: _rentalError(context, controller)),
          ],
          const SizedBox(height: 16),
          _ActionButton(
            key: const ValueKey('rent-confirm-dock'),
            label: context.l10n.confirmBikeDocked,
            icon: Icons.lock_rounded,
            busy: controller.isBusy,
            onPressed: () => controller.confirmDock(),
          ),
        ],
      ),
    );
  }
}
