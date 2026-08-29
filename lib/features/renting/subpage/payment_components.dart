part of '../renting_flow_page.dart';

class _FareCalculationPanel extends StatelessWidget {
  const _FareCalculationPanel({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.tertiary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, color: scheme.tertiary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.timeBasedPricing,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              context.l10n.pricingFormula(
                context.formats.currency(controller.unlockFee),
                context.formats.currency(controller.perMinuteRate),
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PriceRow(
            label: context.l10n.pricingExample(10),
            value: context.formats.currency(
              controller.unlockFee + (10 * controller.perMinuteRate),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.pricingTimerDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(value, textAlign: TextAlign.right, style: style),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.method});

  final RentalPaymentMethod method;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.account_balance_wallet_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${method.brand}\n${_paymentMethodLabel(context.l10n, method)}',
              style: const TextStyle(height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
