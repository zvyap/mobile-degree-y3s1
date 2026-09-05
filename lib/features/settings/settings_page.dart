import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/repositories/auth_repository.dart';
import 'package:bike_renting_app/data/repositories/payment_method_repository.dart';
import 'package:bike_renting_app/features/legal/legal.dart';
import 'package:bike_renting_app/features/payment_methods/pages/payment_methods_page.dart';
import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({
    super.key,
    required this.onToggleTheme,
    this.onLocaleChanged,
    this.currentLocale,
    this.paymentMethodRepository,
  });

  final ValueChanged<Brightness> onToggleTheme;
  final ValueChanged<Locale?>? onLocaleChanged;
  final Locale? currentLocale;
  final PaymentMethodRepository? paymentMethodRepository;
  final AuthRepository auth = AuthRepository();

  PaymentMethodRepository _resolveRepository() {
    return paymentMethodRepository ??
        PaymentMethodRepository(
          SupabaseDatabaseDataSource(Supabase.instance.client),
        );
  }

  Locale _resolveActiveLocale(BuildContext context) {
    if (currentLocale != null) {
      return currentLocale!;
    }
    final scopeLocale = AppLocaleScope.maybeOf(context)?.locale;
    if (scopeLocale != null) {
      return scopeLocale;
    }
    try {
      return Localizations.localeOf(context);
    } catch (_) {
      return const Locale('en');
    }
  }

  void _handleLocaleChange(BuildContext context, Locale newLocale) {
    if (onLocaleChanged != null) {
      onLocaleChanged!(newLocale);
    } else {
      AppLocaleScope.maybeOf(context)?.onLocaleChanged(newLocale);
    }
  }

  String _getLocaleDisplayName(BuildContext context, Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return context.l10n.english;
      case 'ms':
        return context.l10n.malay;
      case 'zh':
        return context.l10n.simplifiedChinese;
      default:
        return locale.languageCode.toUpperCase();
    }
  }

  Future<void> _showLanguageDialog(
    BuildContext context,
    Locale activeLocale,
  ) async {
    final selected = await showDialog<Locale>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(context.l10n.selectLanguage),
          contentPadding: const EdgeInsets.only(top: 16, bottom: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLocalizations.supportedLocales.map((locale) {
              final isSelected =
                  locale.languageCode == activeLocale.languageCode;
              return ListTile(
                key: ValueKey<String>(
                  'settings-language-option-${locale.languageCode}',
                ),
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: isSelected
                      ? Theme.of(dialogContext).colorScheme.primary
                      : null,
                ),
                title: Text(_getLocaleDisplayName(context, locale)),
                selected: isSelected,
                onTap: () => Navigator.of(dialogContext).pop(locale),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(context.l10n.cancel),
            ),
          ],
        );
      },
    );

    if (selected != null && context.mounted) {
      _handleLocaleChange(context, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final activeLocale = _resolveActiveLocale(context);
    final supportedCodes = AppLocalizations.supportedLocales
        .map((locale) => locale.languageCode)
        .toSet();
    final dropdownValue = supportedCodes.contains(activeLocale.languageCode)
        ? activeLocale.languageCode
        : (supportedCodes.isNotEmpty ? supportedCodes.first : 'en');

    return ListView(
      key: const ValueKey<String>('settings-page'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          context.l10n.appSettings,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.appSettingsDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: 12),
        ListTile(
          key: const ValueKey<String>('settings-language'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const Icon(Icons.language_rounded),
          title: Text(context.l10n.language),
          subtitle: Text(context.l10n.languageDescription),
          trailing: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              key: const ValueKey<String>('settings-language-dropdown'),
              value: dropdownValue,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              items: AppLocalizations.supportedLocales.map((locale) {
                return DropdownMenuItem<String>(
                  key: ValueKey<String>(
                    'settings-language-${locale.languageCode}',
                  ),
                  value: locale.languageCode,
                  child: Text(_getLocaleDisplayName(context, locale)),
                );
              }).toList(),
              onChanged: (newCode) {
                if (newCode != null) {
                  _handleLocaleChange(context, Locale(newCode));
                }
              },
            ),
          ),
          onTap: () => _showLanguageDialog(context, activeLocale),
        ),
        const Divider(),
        SwitchListTile(
          key: const ValueKey<String>('settings-theme'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          secondary: Icon(
            isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
          ),
          title: Text(context.l10n.darkTheme),
          subtitle: Text(isDark ? context.l10n.on : context.l10n.off),
          value: isDark,
          onChanged: (_) => onToggleTheme(theme.brightness),
        ),
        const Divider(),
        ListTile(
          key: const ValueKey<String>('settings-payment-methods'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const Icon(Icons.payment_rounded),
          title: Text(context.l10n.paymentMethod),
          subtitle: Text(context.l10n.managePaymentMethodsSubtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                settings: const RouteSettings(
                  name: '/settings/payment-methods',
                  arguments: AppPage.paymentMethods,
                ),
                builder: (context) => PaymentMethodsPage(
                  repository: _resolveRepository(),
                ),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          key: const ValueKey<String>('settings-terms-of-service'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const Icon(Icons.description_outlined),
          title: Text(context.l10n.termsOfService),
          subtitle: Text(context.l10n.termsOfServiceSubtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => TermsOfServicePage.open(context),
        ),
        ListTile(
          key: const ValueKey<String>('settings-privacy-policy'),
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const Icon(Icons.privacy_tip_outlined),
          title: Text(context.l10n.privacyPolicy),
          subtitle: Text(context.l10n.privacyPolicySubtitle),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => PrivacyPolicyPage.open(context),
        ),

        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () async {await auth.logout();},
            icon: const Icon(Icons.logout_rounded),
            label: Text(
              context.l10n.logOut,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),

      ],
    );
  }
}
