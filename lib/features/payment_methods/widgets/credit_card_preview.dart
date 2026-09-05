import 'package:bike_renting_app/features/payment_methods/models/card_brand.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class CreditCardPreview extends StatelessWidget {
  const CreditCardPreview({
    super.key,
    required this.cardNumber,
    required this.cardholderName,
    required this.expiryDate,
    required this.brand,
  });

  final String cardNumber;
  final String cardholderName;
  final String expiryDate;
  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayedNumber = _formatDisplayNumber(cardNumber);
    final displayedName = cardholderName.trim().isEmpty
        ? context.l10n.cardholderNamePreview
        : cardholderName.trim().toUpperCase();
    final displayedExpiry =
        expiryDate.trim().isEmpty ? 'MM/YY' : expiryDate.trim();

    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1E293B),
              Color(0xFF0F172A),
              Color(0xFF1E1B4B),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top row: EMV Chip & Card Brand Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 44,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFFFFBEB),
                      width: 0.8,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(width: 1, color: Colors.black26),
                      Container(width: 1, color: Colors.black26),
                    ],
                  ),
                ),
                _BrandBadge(brand: brand),
              ],
            ),

            // Middle row: Card Number
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                displayedNumber,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      offset: Offset(0, 1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom row: Cardholder Name & Expiry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.l10n.cardholderPreview,
                        style: TextStyle(
                          fontSize: 9,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        displayedName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.l10n.expiresPreview,
                      style: TextStyle(
                        fontSize: 9,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      displayedExpiry,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDisplayNumber(String input) {
    final clean = input.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      return '•••• •••• •••• ••••';
    }

    if (input.contains('•') || input.contains('*')) {
      return '•••• •••• •••• ${clean.length >= 4 ? clean.substring(clean.length - 4) : clean.padLeft(4, '•')}';
    }

    final buffer = StringBuffer();
    for (int i = 0; i < 16; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      if (i < clean.length) {
        buffer.write(clean[i]);
      } else {
        buffer.write('•');
      }
    }
    return buffer.toString();
  }
}

class _BrandBadge extends StatelessWidget {
  const _BrandBadge({required this.brand});

  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    final brandColor = switch (brand) {
      CardBrand.visa => const Color(0xFF1A1F71),
      CardBrand.mastercard => const Color(0xFFEB001B),
      CardBrand.unknown => Colors.white.withValues(alpha: 0.15),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: brandColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.25),
        ),
      ),
      child: Text(
        brand.displayName.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 12,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}
