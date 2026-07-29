import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.onToggleTheme});

  final ValueChanged<Brightness> onToggleTheme;

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
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const Icon(Icons.location_on_outlined),
          title: Text(context.l10n.locationAccess),
          subtitle: Text(context.l10n.locationAccessDescription),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          leading: const Icon(Icons.notifications_outlined),
          title: Text(context.l10n.rideNotifications),
          subtitle: Text(context.l10n.rideNotificationsDescription),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
