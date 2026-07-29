part of '../renting_flow_page.dart';

class _UnlockStage extends StatelessWidget {
  const _UnlockStage({required this.controller});

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
            icon: Icons.lock_open_rounded,
            title: context.l10n.unlockBikeTitle,
            subtitle: context.l10n.unlockBikeDescription(controller.bike.id),
          ),
          const SizedBox(height: 18),
          AnimatedContainer(
            duration: motionDuration(context, 220),
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.32),
                width: 2,
              ),
            ),
            child: controller.isBusy
                ? Padding(
                    padding: const EdgeInsets.all(26),
                    child: CircularProgressIndicator(color: scheme.primary),
                  )
                : Icon(
                    Icons.lock_open_rounded,
                    size: 40,
                    color: scheme.primary,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            controller.isBusy
                ? context.l10n.contactingBikeLock
                : context.l10n.cardHoldAuthorized,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (controller.error != null) ...[
            const SizedBox(height: 18),
            _ErrorPanel(message: _rentalError(context, controller)),
          ],
          const SizedBox(height: 16),
          _ActionButton(
            key: const ValueKey('rent-unlock'),
            label: context.l10n.unlockBike,
            icon: Icons.play_arrow_rounded,
            busy: controller.isBusy,
            onPressed: () => controller.unlockBike(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const ValueKey('rent-cancel'),
            style: _secondaryTextButtonStyle(context),
            onPressed: controller.isBusy ? null : controller.reset,
            icon: const Icon(Icons.close_rounded),
            label: Text(context.l10n.cancelRental),
          ),
        ],
      ),
    );
  }
}
