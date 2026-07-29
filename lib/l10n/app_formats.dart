import 'package:bike_renting_app/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class AppFormats {
  AppFormats(Locale locale)
    : _localeName = Intl.canonicalizedLocale(locale.toLanguageTag());

  final String _localeName;

  String currency(num amount) {
    return NumberFormat.simpleCurrency(
      locale: _localeName,
      name: appCurrencyCode,
    ).format(amount);
  }

  String date(DateTime value) => DateFormat.yMMMd(_localeName).format(value);

  String time(DateTime value) => DateFormat.jm(_localeName).format(value);

  String duration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final twoDigits = NumberFormat('00', _localeName);
    return '${twoDigits.format(minutes)}:${twoDigits.format(seconds)}';
  }

  String decimal(num value, {int decimalDigits = 2}) {
    final format = NumberFormat.decimalPatternDigits(
      locale: _localeName,
      decimalDigits: decimalDigits,
    );
    return format.format(value);
  }
}

extension AppFormatsBuildContext on BuildContext {
  AppFormats get formats => AppFormats(Localizations.localeOf(this));
}
