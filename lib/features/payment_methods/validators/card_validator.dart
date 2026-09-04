import 'package:bike_renting_app/features/payment_methods/models/card_brand.dart';
import 'package:flutter/services.dart';

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

  /// Full validation for Card Number with inline error message.
  static String? validateCardNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Card number is required';
    }

    final digits = cleanDigits(value);
    if (digits.isEmpty) {
      return 'Enter valid card digits';
    }

    final brand = CardBrand.detect(digits);
    if (brand == CardBrand.unknown) {
      return 'Only Visa and Mastercard are supported';
    }

    if (digits.length < 16) {
      return 'Card number must be 16 digits (${digits.length}/16)';
    }

    if (digits.length > 16) {
      return 'Card number exceeds 16 digits';
    }

    if (!isValidLuhn(digits)) {
      return 'Invalid card number (checksum failed)';
    }

    return null;
  }

  /// Full validation for Expiry Date (MM/YY) with inline error message.
  static String? validateExpiry(String? value, [DateTime? currentDate]) {
    if (value == null || value.trim().isEmpty) {
      return 'Expiry date is required';
    }

    final trimmed = value.trim();
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(trimmed)) {
      return 'Enter expiry date as MM/YY';
    }

    final parts = trimmed.split('/');
    final month = int.tryParse(parts[0]);
    final yearPart = int.tryParse(parts[1]);

    if (month == null || month < 1 || month > 12) {
      return 'Invalid month (must be 01–12)';
    }

    if (yearPart == null) {
      return 'Invalid expiry year';
    }

    final fullYear = 2000 + yearPart;
    final now = currentDate ?? DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    if (fullYear < currentYear || (fullYear == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }

    if (fullYear > currentYear + 20) {
      return 'Expiry year too far in future';
    }

    return null;
  }

  /// Full validation for CVV / CVC with inline error message.
  static String? validateCvv(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CVV code is required';
    }

    final trimmed = value.trim();
    if (!RegExp(r'^\d{3}$').hasMatch(trimmed)) {
      return 'CVV must be 3 digits';
    }

    return null;
  }

  /// Full validation for Cardholder Name with inline error message.
  static String? validateCardholderName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Cardholder name is required';
    }

    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (trimmed.length > 50) {
      return 'Name cannot exceed 50 characters';
    }

    if (!RegExp(r"^[a-zA-Z\s\.\'\-]+$").hasMatch(trimmed)) {
      return 'Only letters, spaces, hyphens, and dots allowed';
    }

    if (!trimmed.contains(' ')) {
      return 'Please enter first and last name';
    }

    return null;
  }
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
      selection: TextSelection.collapsed(offset: formatted.length),
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
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
