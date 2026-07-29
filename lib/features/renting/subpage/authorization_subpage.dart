part of '../renting_flow_page.dart';

class _AuthorizationStage extends StatelessWidget {
  const _AuthorizationStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageTitle(
            icon: Icons.lock_clock_rounded,
            title: context.l10n.authorizeCardHold,
            subtitle: context.l10n.authorizeCardHoldDescription,
          ),
          const SizedBox(height: 14),
          Center(
            child: Column(
              children: [
                Text(
                  context.formats.currency(RentingController.holdAmount),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(context.l10n.temporaryAuthorizationHold),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _PaymentMethodTile(method: controller.selectedPaymentMethod!),
          if (controller.error != null) ...[
            const SizedBox(height: 16),
            _ErrorPanel(message: _rentalError(context, controller)),
          ],
          const SizedBox(height: 14),
          _ActionButton(
            key: const ValueKey('rent-authorize'),
            label: context.l10n.authorizeHold(
              context.formats.currency(RentingController.holdAmount),
            ),
            icon: Icons.verified_user_rounded,
            busy: controller.isBusy,
            onPressed: () => controller.authorizeHold(),
          ),
          const SizedBox(height: 8),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton.icon(
                  style: _secondaryTextButtonStyle(context),
                  onPressed: controller.isBusy
                      ? null
                      : controller.backToBikeCheck,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(context.l10n.back),
                ),
                TextButton.icon(
                  key: const ValueKey('rent-cancel'),
                  style: _secondaryTextButtonStyle(context),
                  onPressed: controller.isBusy ? null : controller.reset,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(context.l10n.cancelRental),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
