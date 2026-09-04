import 'package:flutter/material.dart';

enum CardBrand {
  visa('Visa'),
  mastercard('Mastercard'),
  unknown('Card');

  const CardBrand(this.displayName);

  final String displayName;

  static CardBrand detect(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return CardBrand.unknown;

    if (digits.startsWith('4')) {
      return CardBrand.visa;
    }

    if (digits.length >= 2) {
      final prefix2 = int.tryParse(digits.substring(0, 2)) ?? 0;
      if (prefix2 >= 51 && prefix2 <= 55) {
        return CardBrand.mastercard;
      }
    }

    if (digits.length >= 4) {
      final prefix4 = int.tryParse(digits.substring(0, 4)) ?? 0;
      if (prefix4 >= 2221 && prefix4 <= 2720) {
        return CardBrand.mastercard;
      }
    }

    return CardBrand.unknown;
  }

  IconData get icon => switch (this) {
    CardBrand.visa => Icons.credit_card_rounded,
    CardBrand.mastercard => Icons.credit_score_rounded,
    CardBrand.unknown => Icons.payment_rounded,
  };
}
