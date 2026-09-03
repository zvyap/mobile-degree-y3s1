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
          _PriceRow(
            label: context.l10n.depositHeld,
            value: context.formats.currency(controller.holdAmount),
            strong: true,
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

class _DepositSummaryTile extends StatelessWidget {
  const _DepositSummaryTile({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.depositHeld,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.holdExplanation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            context.formats.currency(controller.holdAmount),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: scheme.primary,
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
  const _PaymentMethodTile({required this.method, this.onTap});

  final RentalPaymentMethod method;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final choosable = onTap != null;
    final tile = Ink(
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.all(14),
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
            if (choosable) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ],
        ),
      ),
    );
    return Semantics(
      button: choosable,
      child: Material(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(8),
        child: choosable
            ? InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(8),
                child: tile,
              )
            : tile,
      ),
    );
  }
}

Future<void> _showPaymentMethodPicker(
  BuildContext context,
  RentingController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => _PaymentMethodPickerSheet(controller: controller),
  );
}

class _PaymentMethodPickerSheet extends StatelessWidget {
  const _PaymentMethodPickerSheet({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.choosePaymentMethod,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            for (final method in controller.availablePaymentMethods)
              _PaymentMethodOption(
                method: method,
                selected: method.id == controller.selectedPaymentMethod?.id,
                onTap: () {
                  controller.selectPaymentMethod(method);
                  Navigator.of(context).pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodOption extends StatelessWidget {
  const _PaymentMethodOption({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final RentalPaymentMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.09)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          key: ValueKey<String>('rent-payment-${method.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(_methodIcon(method.id), color: scheme.primary, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${method.brand}\n${_paymentMethodLabel(context.l10n, method)}',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ),
                if (selected)
                  Icon(Icons.check_rounded, color: scheme.primary, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

IconData _methodIcon(String methodId) {
  return methodId == 'paypal'
      ? Icons.account_balance_wallet_rounded
      : Icons.credit_card_rounded;
}
