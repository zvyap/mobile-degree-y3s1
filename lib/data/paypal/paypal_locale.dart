import 'dart:ui';
import 'package:flutter/widgets.dart';

class PayPalLocale {
  const PayPalLocale({
    required this.bcp47,
    required this.webCode,
  });

  final String bcp47;
  final String webCode;

  static const defaultLocale = PayPalLocale(
    bcp47: 'en-MY',
    webCode: 'en_US',
  );

  static const supportedLocales = <PayPalLocale>[
    PayPalLocale(bcp47: 'en-MY', webCode: 'en_US'),
    PayPalLocale(bcp47: 'en-US', webCode: 'en_US'),
    PayPalLocale(bcp47: 'ms-MY', webCode: 'ms_MY'),
    PayPalLocale(bcp47: 'zh-CN', webCode: 'zh_CN'),
    PayPalLocale(bcp47: 'zh-HK', webCode: 'zh_HK'),
    PayPalLocale(bcp47: 'zh-TW', webCode: 'zh_TW'),
  ];

  static PayPalLocale fromLocale(Locale? locale) {
    if (locale == null) return defaultLocale;
    final lang = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toUpperCase();
    final script = locale.scriptCode?.toLowerCase();

    // Chinese (Simplified and Traditional)
    if (lang == 'zh') {
      if (script == 'hant' || country == 'HK') {
        return const PayPalLocale(bcp47: 'zh-HK', webCode: 'zh_HK');
      }
      if (country == 'TW') {
        return const PayPalLocale(bcp47: 'zh-TW', webCode: 'zh_TW');
      }
      return const PayPalLocale(bcp47: 'zh-CN', webCode: 'zh_CN');
    }

    // Bahasa Melayu
    if (lang == 'ms') {
      return const PayPalLocale(bcp47: 'ms-MY', webCode: 'ms_MY');
    }

    // English
    if (lang == 'en') {
      if (country == 'MY') {
        return defaultLocale;
      }
      return const PayPalLocale(bcp47: 'en-US', webCode: 'en_US');
    }

    return defaultLocale;
  }

  static PayPalLocale fromCode(String? code) {
    if (code == null || code.isEmpty) return defaultLocale;
    final cleaned = code.trim().replaceAll('_', '-').toLowerCase();

    if (cleaned == 'zh' || cleaned.startsWith('zh-cn') || cleaned.startsWith('zh-hans')) {
      return const PayPalLocale(bcp47: 'zh-CN', webCode: 'zh_CN');
    }
    if (cleaned == 'zh-hk' || cleaned == 'zh-tw' || cleaned.startsWith('zh-hant')) {
      return cleaned.contains('tw')
          ? const PayPalLocale(bcp47: 'zh-TW', webCode: 'zh_TW')
          : const PayPalLocale(bcp47: 'zh-HK', webCode: 'zh_HK');
    }
    if (cleaned == 'ms' || cleaned.startsWith('ms-')) {
      return const PayPalLocale(bcp47: 'ms-MY', webCode: 'ms_MY');
    }
    if (cleaned == 'en' || cleaned.startsWith('en-')) {
      return cleaned == 'en-my'
          ? defaultLocale
          : const PayPalLocale(bcp47: 'en-US', webCode: 'en_US');
    }

    return defaultLocale;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PayPalLocale &&
          runtimeType == other.runtimeType &&
          bcp47 == other.bcp47;

  @override
  int get hashCode => bcp47.hashCode;

  @override
  String toString() => 'PayPalLocale($bcp47, $webCode)';
}

class PayPalLocaleService {
  PayPalLocaleService._();

  /// Resolves the client device's language automatically.
  /// Inspects client phone's system locales directly from PlatformDispatcher
  /// so Flutter's English-only MaterialApp supportedLocales doesn't mask device language.
  static PayPalLocale resolveClientLocale([BuildContext? context]) {
    // 1. Check client phone's actual system locales list
    try {
      final systemLocales = PlatformDispatcher.instance.locales;
      if (systemLocales.isNotEmpty) {
        return PayPalLocale.fromLocale(systemLocales.first);
      }
    } catch (_) {}

    // 2. Check client phone's single primary locale
    try {
      final primary = PlatformDispatcher.instance.locale;
      return PayPalLocale.fromLocale(primary);
    } catch (_) {}

    // 3. Fallback to context if available
    if (context != null) {
      try {
        final loc = Localizations.maybeLocaleOf(context);
        if (loc != null) {
          return PayPalLocale.fromLocale(loc);
        }
      } catch (_) {}
    }

    return PayPalLocale.defaultLocale;
  }

  static Uri applyLocaleToUrl(Uri uri, String webCode) {
    final params = Map<String, String>.from(uri.queryParameters);
    params['locale.x'] = webCode;
    return uri.replace(queryParameters: params);
  }

  static Map<String, String> buildHeaders(String bcp47) {
    final prefix = bcp47.split('-').first;
    return {
      'Accept-Language': '$bcp47,$prefix;q=0.9,en-US;q=0.8,en;q=0.7',
    };
  }
}
