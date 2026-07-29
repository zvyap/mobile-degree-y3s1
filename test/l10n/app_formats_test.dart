import 'package:bike_renting_app/constants.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

void main() {
  final formats = AppFormats(const Locale('en'));

  setUpAll(() => initializeDateFormatting('en'));

  test('formats currency using configured currency code', () {
    final expected = NumberFormat.simpleCurrency(
      locale: 'en',
      name: appCurrencyCode,
    ).format(0.5);

    expect(formats.currency(0.5), expected);
  });

  test('formats date, time, and elapsed duration using intl', () {
    final value = DateTime(2026, 7, 29, 10, 30);

    expect(formats.date(value), DateFormat.yMMMd('en').format(value));
    expect(formats.time(value), DateFormat.jm('en').format(value));
    expect(formats.duration(65), '01:05');
  });
}
