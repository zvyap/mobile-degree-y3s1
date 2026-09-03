part of '../renting_flow_page.dart';

class _ChargeStage extends StatelessWidget {
  const _ChargeStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageTitle(
            icon: Icons.receipt_long_rounded,
            title: context.l10n.rideComplete,
            subtitle: context.l10n.rideCompleteDescription,
          ),
          const SizedBox(height: 14),
          _PriceRow(
            label: context.l10n.unlockFee,
            value: context.formats.currency(controller.unlockFee),
          ),
          const SizedBox(height: 10),
          _PriceRow(
            label: context.l10n.rideDuration,
            value: _durationWords(context.l10n, controller.chargedMinutes),
          ),
          const SizedBox(height: 10),
          _PriceRow(
            label: context.l10n.timeFare,
            value: context.formats.currency(
              controller.chargedMinutes * controller.perMinuteRate,
            ),
          ),
          const Divider(height: 22),
          _PriceRow(
            label: context.l10n.finalFare,
            value: context.formats.currency(controller.estimatedFare),
            strong: true,
          ),
          const SizedBox(height: 10),
          _PriceRow(
            label: context.l10n.holdReleased,
            value: context.formats.currency(controller.releasedHold),
          ),
          const SizedBox(height: 14),
          _PaymentMethodTile(method: controller.selectedPaymentMethod!),
          const SizedBox(height: 14),
          _ActionButton(
            key: const ValueKey('rent-charge'),
            label: context.l10n.chargeAmount(
              context.formats.currency(controller.estimatedFare),
            ),
            icon: Icons.credit_score_rounded,
            busy: controller.isBusy,
            onPressed: () => controller.capturePayment(),
          ),
        ],
      ),
    );
  }
}
