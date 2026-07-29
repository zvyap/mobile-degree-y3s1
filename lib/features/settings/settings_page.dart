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
          'App settings',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage appearance and ride permissions.',
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
          title: const Text('Dark theme'),
          subtitle: Text(isDark ? 'On' : 'Off'),
          value: isDark,
          onChanged: (_) => onToggleTheme(theme.brightness),
        ),
        const Divider(),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(Icons.location_on_outlined),
          title: Text('Location access'),
          subtitle: Text('Required while a ride is active'),
          trailing: Icon(Icons.chevron_right_rounded),
        ),
        const ListTile(
          contentPadding: EdgeInsets.symmetric(horizontal: 4),
          leading: Icon(Icons.notifications_outlined),
          title: Text('Ride notifications'),
          subtitle: Text('Return reminders and payment updates'),
          trailing: Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }
}
