import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/repositories/auth_repository.dart';
import 'package:bike_renting_app/data/repositories/payment_method_repository.dart';
import 'package:bike_renting_app/features/legal/legal.dart';
import 'package:bike_renting_app/features/payment_methods/pages/payment_methods_page.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatelessWidget {
  SettingsPage({
    super.key,
    required this.onToggleTheme,
    this.paymentMethodRepository,
  });

  final ValueChanged<Brightness> onToggleTheme;
  final PaymentMethodRepository? paymentMethodRepository;
  final AuthRepository auth = AuthRepository();

  PaymentMethodRepository _resolveRepository() {
    return paymentMethodRepository ??
        PaymentMethodRepository(
          SupabaseDatabaseDataSource(Supabase.instance.client),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

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
