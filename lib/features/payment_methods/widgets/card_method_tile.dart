import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/payment_methods/models/card_brand.dart';
import 'package:flutter/material.dart';

class CardMethodTile extends StatelessWidget {
  const CardMethodTile({
    super.key,
    required this.card,
    required this.onEdit,
    required this.onDelete,
    required this.onSetDefault,
  });

  final PaymentMethodRecord card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSetDefault;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brand = CardBrand.detect(card.brand.toLowerCase());

    final expiryText = card.expiryMonth != null && card.expiryYear != null
        ? 'Exp ${card.expiryMonth.toString().padLeft(2, '0')}/${(card.expiryYear! % 100).toString().padLeft(2, '0')}'
        : 'Active Card';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: card.isDefault
            ? scheme.primaryContainer.withValues(alpha: 0.15)
            : scheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: card.isDefault
                ? scheme.primary.withValues(alpha: 0.5)
                : scheme.outlineVariant,
            width: card.isDefault ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            brand.icon,
            color: scheme.primary,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '${card.brand} •••• ${card.lastFour}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (card.isDefault)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'DEFAULT',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            if (card.cardholderName != null && card.cardholderName!.isNotEmpty)
              Text(
                card.cardholderName!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            Text(
              expiryText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded),
          tooltip: 'Card options',
          onSelected: (value) {
            switch (value) {
              case 'default':
                onSetDefault();
                break;
              case 'edit':
                onEdit();
                break;
              case 'delete':
                onDelete();
                break;
            }
          },
          itemBuilder: (context) => [
            if (!card.isDefault)
              const PopupMenuItem<String>(
                value: 'default',
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 20),
                    SizedBox(width: 10),
                    Text('Set as default'),
                  ],
                ),
              ),
            const PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 20),
                  SizedBox(width: 10),
                  Text('Edit card'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline_rounded,
                      size: 20, color: scheme.error),
                  const SizedBox(width: 10),
                  Text('Remove card', style: TextStyle(color: scheme.error)),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
