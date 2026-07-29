part of '../renting_flow_page.dart';

class _ReceiptStage extends StatelessWidget {
  const _ReceiptStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final receipt = controller.receipt!;
    final paid = receipt.paymentStatus == PaymentStatus.paid;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = paid ? scheme.secondary : scheme.tertiary;

    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              paid ? Icons.check_rounded : Icons.schedule_rounded,
              size: 34,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            paid ? context.l10n.ridePaid : context.l10n.paymentPending,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            paid
                ? context.l10n.holdReleasedDescription
                : context.l10n.paymentPendingDescription,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _PriceRow(label: context.l10n.rideId, value: receipt.rideId),
                const SizedBox(height: 10),
                _PriceRow(
                  label: context.l10n.duration,
                  value: context.formats.duration(receipt.elapsedSeconds),
                ),
                const SizedBox(height: 10),
                _PriceRow(
                  label: context.l10n.distance,
                  value: context.l10n.distanceKm(
                    context.formats.decimal(receipt.distanceKm),
                  ),
                ),
                const SizedBox(height: 10),
                _PriceRow(
                  label: context.l10n.returnedAt,
                  value: _stationName(context.l10n, receipt.returnStation),
                ),
                const Divider(height: 28),
                _PriceRow(
                  label: context.l10n.finalFare,
                  value: context.formats.currency(receipt.finalFare),
                  strong: true,
                ),
                const SizedBox(height: 10),
                _PriceRow(
                  label: context.l10n.holdReleased,
                  value: context.formats.currency(receipt.releasedHold),
                ),
              ],
            ),
          ),
          if (!paid) ...[
            const SizedBox(height: 18),
            _ActionButton(
              key: const ValueKey('rent-retry-payment'),
              label: context.l10n.retryPayment,
              icon: Icons.refresh_rounded,
              busy: controller.isBusy,
              onPressed: controller.retryPayment,
            ),
          ],
          const SizedBox(height: 18),
          OutlinedButton.icon(
            key: const ValueKey('rent-reset'),
            onPressed: controller.isBusy ? null : controller.reset,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text(context.l10n.rentAnotherBike),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}
