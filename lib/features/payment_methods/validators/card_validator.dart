import 'package:bike_renting_app/features/payment_methods/models/card_brand.dart';
import 'package:flutter/services.dart';

/// Typed validation outcomes for the card form fields.
enum CardValidationError {
  cardNumberRequired,
  cardDigitsOnly,
  cardBrandUnsupported,
  cardNumberLength,
  cardNumberTooLong,
  cardChecksumFailed,
  expiryRequired,
  expiryFormat,
  expiryInvalidMonth,
  expiryInvalidYear,
  cardExpired,
  expiryTooFar,
  cvvRequired,
  cvvLength,
  nameRequired,
  nameTooShort,
  nameTooLong,
  nameInvalidChars,
  nameNeedsTwoParts,
  nameDuplicate,
}

class CardValidator {
  const CardValidator._();

  static String cleanDigits(String value) {
    return value.replaceAll(RegExp(r'\D'), '');
  }

  /// Real-world Luhn algorithm (Modulo 10) mathematical checksum validation.
  static bool isValidLuhn(String cardNumber) {
    final digits = cleanDigits(cardNumber);
    if (digits.length < 13 || digits.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      final codeUnit = digits.codeUnitAt(i);
      if (codeUnit < 48 || codeUnit > 57) return false;
      int n = codeUnit - 48;

      if (alternate) {
        n *= 2;
        if (n > 9) {
          n -= 9;
        }
      }
      sum += n;
      alternate = !alternate;
    }

    return (sum % 10) == 0;
  }

  /// Full validation for Card Number.
  static CardValidationError? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return CardValidationError.cardNumberRequired;
    }

    final digits = cleanDigits(value);
    if (digits.isEmpty) {
      return CardValidationError.cardDigitsOnly;
    }

    final brand = CardBrand.detect(digits);
    if (brand == CardBrand.unknown) {
      return CardValidationError.cardBrandUnsupported;
    }

    if (digits.length < 16) {
      return CardValidationError.cardNumberLength;
    }

    if (digits.length > 16) {
      return CardValidationError.cardNumberTooLong;
    }

    if (!isValidLuhn(digits)) {
      return CardValidationError.cardChecksumFailed;
    }

    return null;
  }

  /// Full validation for Expiry Date (MM/YY).
  static CardValidationError? validateExpiry(String? value, [DateTime? currentDate]) {
    if (value == null || value.trim().isEmpty) {
      return CardValidationError.expiryRequired;
    }

    final trimmed = value.trim();
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(trimmed)) {
      return CardValidationError.expiryFormat;
    }

    final parts = trimmed.split('/');
    final month = int.tryParse(parts[0]);
    final yearPart = int.tryParse(parts[1]);

    if (month == null || month < 1 || month > 12) {
      return CardValidationError.expiryInvalidMonth;
    }

    if (yearPart == null) {
      return CardValidationError.expiryInvalidYear;
    }

    final fullYear = 2000 + yearPart;
    final now = currentDate ?? DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    if (fullYear < currentYear || (fullYear == currentYear && month < currentMonth)) {
      return CardValidationError.cardExpired;
    }

    if (fullYear > currentYear + 20) {
      return CardValidationError.expiryTooFar;
    }

    return null;
  }

  /// Full validation for CVV / CVC.
  static CardValidationError? validateCvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return CardValidationError.cvvRequired;
    }

    final trimmed = value.trim();
    if (!RegExp(r'^\d{3}$').hasMatch(trimmed)) {
      return CardValidationError.cvvLength;
    }

    return null;
  }

  /// Full validation for Cardholder Name.
  /// Supports Malaysian naming conventions including Indian patronymics (A/L, A/P, S/O, D/O).
  static CardValidationError? validateCardholderName(
    String? value, {
    Iterable<String?> existingNames = const [],
  }) {
    if (value == null || value.trim().isEmpty) {
      return CardValidationError.nameRequired;
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return CardValidationError.nameTooShort;
    }

    if (trimmed.length > 50) {
      return CardValidationError.nameTooLong;
    }

    if (!RegExp(r"^[a-zA-Z\s\.\'/\-]+$").hasMatch(trimmed) ||
        !RegExp(r'[a-zA-Z]').hasMatch(trimmed)) {
      return CardValidationError.nameInvalidChars;
    }

    if (!trimmed.contains(' ') && !trimmed.contains('/')) {
      return CardValidationError.nameNeedsTwoParts;
    }

    final lower = trimmed.toLowerCase();
    for (final name in existingNames) {
      if (name != null && name.trim().toLowerCase() == lower) {
        return CardValidationError.nameDuplicate;
      }
    }

    return null;
  }
}

/// Counts digit characters in [value] before the caret position.
int _countDigitsBeforeCaret(TextEditingValue value) {
  var caret = value.text.length;
  final selection = value.selection;
  if (selection.isValid &&
      selection.baseOffset >= 0 &&
      selection.baseOffset <= value.text.length) {
    caret = selection.baseOffset;
  }

  var count = 0;
  for (var i = 0; i < caret; i++) {
    final codeUnit = value.text.codeUnitAt(i);
    if (codeUnit >= 48 && codeUnit <= 57) {
      count++;
    }
  }
  return count;
}

/// Returns the offset in [formatted] right after [digitCount] digits
/// (or the end of the string when there are fewer digits than that).
int _caretAfterDigits(String formatted, int digitCount) {
  if (digitCount <= 0) return 0;

  var seen = 0;
  for (var i = 0; i < formatted.length; i++) {
    final codeUnit = formatted.codeUnitAt(i);
    if (codeUnit >= 48 && codeUnit <= 57) {
      seen++;
      if (seen == digitCount) {
        return i + 1;
      }
    }
  }
  return formatted.length;
}

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = CardValidator.cleanDigits(newValue.text);
    if (text.length > 16) {
      return oldValue;
    }

    final digitsBeforeCaret = _countDigitsBeforeCaret(newValue);

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buffer.write(' ');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _caretAfterDigits(formatted, digitsBeforeCaret),
      ),
    );
  }
}

class CardExpiryInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var text = CardValidator.cleanDigits(newValue.text);
    if (text.length > 4) {
      text = text.substring(0, 4);
    }

    final digitsBeforeCaret = _countDigitsBeforeCaret(newValue);

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(text[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: _caretAfterDigits(formatted, digitsBeforeCaret),
      ),
    );
  }
}
