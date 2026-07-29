import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.page,
    required this.showBackButton,
    required this.onBack,
    required this.showAdminButton,
    required this.onOpenAdmin,
    required this.onOpenSettings,
  });

  final AppPage page;
  final bool showBackButton;
  final VoidCallback onBack;
  final bool showAdminButton;
  final VoidCallback onOpenAdmin;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 8, 4),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              key: const ValueKey<String>('top-back'),
              tooltip: 'Back',
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          Container(
            key: const ValueKey<String>('top-page-icon'),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(page.icon, color: scheme.primary, size: 21),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.title,
                  key: const ValueKey<String>('top-page-title'),
                  maxLines: 2,
                  softWrap: true,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    letterSpacing: 0,
                  ),
                ),
                Text(
                  'BikeRent',
                  softWrap: true,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.68),
                  ),
                ),
              ],
            ),
          ),
          if (showAdminButton)
            IconButton(
              key: const ValueKey<String>('top-admin'),
              tooltip: 'Admin management',
              onPressed: onOpenAdmin,
              icon: const Icon(Icons.admin_panel_settings_rounded),
            ),
          IconButton(
            key: const ValueKey<String>('top-settings'),
            tooltip: 'Settings',
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_rounded),
          ),
        ],
      ),
    );
  }
}
