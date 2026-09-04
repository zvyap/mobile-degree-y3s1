import 'dart:ui';
import 'package:flutter/widgets.dart';

class PayPalLocale {
  const PayPalLocale({
    required this.bcp47,
    required this.webCode,
    required this.displayName,
    this.nativeName = '',
    this.flag = '',
  });

  final String bcp47;
  final String webCode;
  final String displayName;
  final String nativeName;
  final String flag;

  static const defaultLocale = PayPalLocale(
    bcp47: 'en-MY',
    webCode: 'en_US',
    displayName: 'English (Malaysia)',
    nativeName: 'English (MY)',
    flag: '🇲🇾',
  );

  static const supportedLocales = <PayPalLocale>[
    PayPalLocale(
      bcp47: 'en-US',
      webCode: 'en_US',
      displayName: 'English (US)',
      nativeName: 'English (US)',
      flag: '🇺🇸',
    ),
    PayPalLocale(
      bcp47: 'en-MY',
      webCode: 'en_US',
      displayName: 'English (Malaysia)',
      nativeName: 'English (MY)',
      flag: '🇲🇾',
    ),
    PayPalLocale(
      bcp47: 'ms-MY',
      webCode: 'ms_MY',
      displayName: 'Bahasa Melayu',
      nativeName: 'Bahasa Melayu',
      flag: '🇲🇾',
    ),
    PayPalLocale(
      bcp47: 'zh-CN',
      webCode: 'zh_CN',
      displayName: 'Simplified Chinese',
      nativeName: '简体中文',
      flag: '🇨🇳',
    ),
    PayPalLocale(
      bcp47: 'zh-HK',
      webCode: 'zh_HK',
      displayName: 'Traditional Chinese (HK)',
      nativeName: '繁體中文 (香港)',
      flag: '🇭🇰',
    ),
    PayPalLocale(
      bcp47: 'zh-TW',
      webCode: 'zh_TW',
      displayName: 'Traditional Chinese (TW)',
      nativeName: '繁體中文 (台灣)',
      flag: '🇹🇼',
    ),
    PayPalLocale(
      bcp47: 'ja-JP',
      webCode: 'ja_JP',
      displayName: 'Japanese',
      nativeName: '日本語',
      flag: '🇯🇵',
    ),
    PayPalLocale(
      bcp47: 'ko-KR',
      webCode: 'ko_KR',
      displayName: 'Korean',
      nativeName: '한국어',
      flag: '🇰🇷',
    ),
    PayPalLocale(
      bcp47: 'id-ID',
      webCode: 'id_ID',
      displayName: 'Bahasa Indonesia',
      nativeName: 'Bahasa Indonesia',
      flag: '🇮🇩',
    ),
    PayPalLocale(
      bcp47: 'th-TH',
      webCode: 'th_TH',
      displayName: 'Thai',
      nativeName: 'ไทย',
      flag: '🇹🇭',
    ),
    PayPalLocale(
      bcp47: 'vi-VN',
      webCode: 'vi_VN',
      displayName: 'Vietnamese',
      nativeName: 'Tiếng Việt',
      flag: '🇻🇳',
    ),
    PayPalLocale(
      bcp47: 'es-ES',
      webCode: 'es_ES',
      displayName: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸',
    ),
    PayPalLocale(
      bcp47: 'fr-FR',
      webCode: 'fr_FR',
      displayName: 'French',
      nativeName: 'Français',
      flag: '🇫🇷',
    ),
    PayPalLocale(
      bcp47: 'de-DE',
      webCode: 'de_DE',
      displayName: 'German',
      nativeName: 'Deutsch',
      flag: '🇩🇪',
    ),
    PayPalLocale(
      bcp47: 'ar-SA',
      webCode: 'ar_EG',
      displayName: 'Arabic',
      nativeName: 'العربية',
      flag: '🇸🇦',
    ),
  ];

  static PayPalLocale fromLocale(Locale? locale) {
    if (locale == null) return defaultLocale;
    final lang = locale.languageCode.toLowerCase();
    final country = locale.countryCode?.toUpperCase();
    final script = locale.scriptCode?.toLowerCase();

    // Explicit Chinese handling (Simplified vs Traditional)
    if (lang == 'zh') {
      if (script == 'hant' || country == 'HK') {
        return const PayPalLocale(
          bcp47: 'zh-HK',
          webCode: 'zh_HK',
          displayName: 'Traditional Chinese (HK)',
          nativeName: '繁體中文 (香港)',
          flag: '🇭🇰',
        );
      }
      if (country == 'TW') {
        return const PayPalLocale(
          bcp47: 'zh-TW',
          webCode: 'zh_TW',
          displayName: 'Traditional Chinese (TW)',
          nativeName: '繁體中文 (台灣)',
          flag: '🇹🇼',
        );
      }
      // Default Simplified Chinese (CN, MY, SG, Hans, general zh)
      return const PayPalLocale(
        bcp47: 'zh-CN',
        webCode: 'zh_CN',
        displayName: 'Simplified Chinese',
        nativeName: '简体中文',
        flag: '🇨🇳',
      );
    }

    if (country != null) {
      for (final opt in supportedLocales) {
        if (opt.bcp47.toLowerCase() == '$lang-$country'.toLowerCase()) {
          return opt;
        }
      }
    }
    for (final opt in supportedLocales) {
      if (opt.bcp47.split('-').first.toLowerCase() == lang) {
        return opt;
      }
    }
    return defaultLocale;
  }

  static PayPalLocale fromCode(String? code) {
    if (code == null || code.isEmpty) return defaultLocale;
    final cleaned = code.trim().replaceAll('_', '-').toLowerCase();

    // Chinese shorthand
    if (cleaned == 'zh' || cleaned.startsWith('zh-cn') || cleaned.startsWith('zh-hans')) {
      return const PayPalLocale(
        bcp47: 'zh-CN',
        webCode: 'zh_CN',
        displayName: 'Simplified Chinese',
        nativeName: '简体中文',
        flag: '🇨🇳',
      );
    }
    if (cleaned == 'zh-hk' || cleaned == 'zh-tw' || cleaned.startsWith('zh-hant')) {
      return cleaned.contains('tw')
          ? const PayPalLocale(
              bcp47: 'zh-TW',
              webCode: 'zh_TW',
              displayName: 'Traditional Chinese (TW)',
              nativeName: '繁體中文 (台灣)',
              flag: '🇹🇼',
            )
          : const PayPalLocale(
              bcp47: 'zh-HK',
              webCode: 'zh_HK',
              displayName: 'Traditional Chinese (HK)',
              nativeName: '繁體中文 (香港)',
              flag: '🇭🇰',
            );
    }

    for (final opt in supportedLocales) {
      if (opt.bcp47.toLowerCase() == cleaned ||
          opt.webCode.replaceAll('_', '-').toLowerCase() == cleaned ||
          opt.bcp47.split('-').first.toLowerCase() == cleaned) {
        return opt;
      }
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
