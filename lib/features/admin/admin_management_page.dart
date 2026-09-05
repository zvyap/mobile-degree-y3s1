import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:flutter/material.dart';

class AdminManagementPage extends StatelessWidget {
  const AdminManagementPage({
    super.key,
    required this.onNavigate,
    required this.onOpenBikeManagement,
    this.onOpenStationManagement,
    this.onOpenRentingManagement,
  });

  final ValueChanged<AppPage> onNavigate;
  final VoidCallback onOpenBikeManagement;
  final VoidCallback? onOpenStationManagement;
  final VoidCallback? onOpenRentingManagement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      key: const ValueKey<String>('admin-page'),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          context.l10n.adminManagement,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.l10n.adminDescription,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: 12),
        _AdminDestination(
          actionKey: 'admin-rentals',
          icon: Icons.pedal_bike_rounded,
          title: 'Active Rentals',
          subtitle: 'Monitor active renting sessions and end rides',
          onTap: onOpenRentingManagement ?? () => onNavigate(AppPage.rentingManagement),
        ),
        _AdminDestination(
          actionKey: 'admin-stations',
          icon: Icons.map_rounded,
          title: context.l10n.stationManagement,
          subtitle: context.l10n.stationManagementDescription,
          onTap: onOpenStationManagement ?? () => onNavigate(AppPage.stations),
        ),
        _AdminDestination(
          actionKey: 'admin-bikes',
          icon: Icons.directions_bike_rounded,
          title: context.l10n.bikeManagement,
          subtitle: context.l10n.bikeManagementDescription,
          onTap: onOpenBikeManagement,
        ),
        _AdminDestination(
          actionKey: 'admin-users',
          icon: Icons.manage_accounts_rounded,
          title: context.l10n.userManagement,
          subtitle: context.l10n.userManagementDescription,
          onTap: () => onNavigate(AppPage.profile),
        ),
      ],
    );
  }
}

class _AdminDestination extends StatelessWidget {
  const _AdminDestination({
    required this.actionKey,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String actionKey;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey<String>(actionKey),
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      minTileHeight: 64,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle, softWrap: true),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
