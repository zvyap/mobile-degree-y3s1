import 'package:bike_renting_app/features/home/home_page.dart';
import 'package:bike_renting_app/features/modules/module_page.dart';
import 'package:bike_renting_app/features/qr/qr_scan_page.dart';
import 'package:bike_renting_app/features/renting/renting_demo_controller.dart';
import 'package:bike_renting_app/navigation/bike_bottom_nav_bar.dart';
import 'package:bike_renting_app/shared/motion.dart';
import 'package:flutter/material.dart';

class BikeShell extends StatefulWidget {
  const BikeShell({super.key, required this.onToggleTheme});

  final ValueChanged<Brightness> onToggleTheme;

  @override
  State<BikeShell> createState() => _BikeShellState();
}

class _BikeShellState extends State<BikeShell> {
  // Replace with the authenticated user's role when authentication is added.
  static const bool _isAdmin = true;

  int _selectedIndex = 0;
  bool _adminOpen = false;
  bool _bikeManagementOpen = false;
  bool _settingsOpen = false;
  late final RentingDemoController _rentingController;

  @override
  void initState() {
    super.initState();
    _rentingController = RentingDemoController();
  }

  @override
  void dispose() {
    _rentingController.dispose();
    super.dispose();
  }

  void _selectPage(int index) {
    if (_selectedIndex == index &&
        !_adminOpen &&
        !_bikeManagementOpen &&
        !_settingsOpen) {
      return;
    }

    setState(() {
      _selectedIndex = index;
      _adminOpen = false;
      _bikeManagementOpen = false;
      _settingsOpen = false;
    });
  }

  void _openSettings() {
    if (_settingsOpen) return;
    setState(() {
      _adminOpen = false;
      _bikeManagementOpen = false;
      _settingsOpen = true;
    });
  }

  void _openAdmin() {
    if (_adminOpen) return;
    setState(() {
      _adminOpen = true;
      _bikeManagementOpen = false;
      _settingsOpen = false;
    });
  }

  void _openBikeManagement() {
    setState(() {
      _adminOpen = false;
      _bikeManagementOpen = true;
      _settingsOpen = false;
    });
  }

  void _handleBack() {
    if (_bikeManagementOpen) {
      setState(() {
        _bikeManagementOpen = false;
        _adminOpen = true;
      });
      return;
    }
    if (_adminOpen || _settingsOpen) {
      setState(() {
        _adminOpen = false;
        _settingsOpen = false;
      });
      return;
    }
    if (_selectedIndex == 2 && _rentingController.goBack()) {
      return;
    }
    _selectPage(0);
  }

  @override
  Widget build(BuildContext context) {
    final shouldReduceMotion = reduceMotion(context);
    final destination = _bikeManagementOpen
        ? const _HeaderDestination(
            'Bike management',
            Icons.directions_bike_rounded,
          )
        : _adminOpen
        ? const _HeaderDestination(
            'Admin management',
            Icons.admin_panel_settings_rounded,
          )
        : _settingsOpen
        ? const _HeaderDestination('Settings', Icons.settings_rounded)
        : _destinations[_selectedIndex];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _rentingController,
              builder: (context, child) => _AppHeader(
                title: destination.title,
                icon: destination.icon,
                showBackButton:
                    _adminOpen ||
                    _bikeManagementOpen ||
                    _settingsOpen ||
                    (_selectedIndex == 2 && _rentingController.canGoBack),
                onBack: _handleBack,
                showAdminButton: _isAdmin,
                onOpenAdmin: _openAdmin,
                onOpenSettings: _openSettings,
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: shouldReduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  if (shouldReduceMotion) {
                    return child;
                  }

                  final curved = CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  );

                  return FadeTransition(
                    opacity: curved,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.04, 0),
                        end: Offset.zero,
                      ).animate(curved),
                      child: child,
                    ),
                  );
                },
                child: _bikeManagementOpen
                    ? const ModulePage(
                        key: ValueKey<String>('bike-management-page'),
                        title: 'Bike management',
                        subtitle:
                            'Fleet health, battery status, and maintenance queue.',
                        icon: Icons.directions_bike_rounded,
                        accent: Color(0xFF0E9F6E),
                      )
                    : _adminOpen
                    ? _AdminManagementPage(
                        key: const ValueKey<String>('admin-page'),
                        onNavigate: _selectPage,
                        onOpenBikeManagement: _openBikeManagement,
                      )
                    : _settingsOpen
                    ? _SettingsPage(
                        key: const ValueKey<String>('settings-page'),
                        onToggleTheme: widget.onToggleTheme,
                      )
                    : _PageContent(
                        key: ValueKey<int>(_selectedIndex),
                        selectedIndex: _selectedIndex,
                        rentingController: _rentingController,
                        onRequestExit: _selectPage,
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BikeBottomNavBar(
        selectedIndex: _selectedIndex,
        onSelected: _selectPage,
      ),
    );
  }
}

const _destinations = [
  _HeaderDestination('Home', Icons.home_rounded),
  _HeaderDestination('Stations', Icons.map_rounded),
  _HeaderDestination('Bike Session', Icons.qr_code_scanner_rounded),
  _HeaderDestination('History', Icons.history_rounded),
  _HeaderDestination('Profile', Icons.person_rounded),
];

class _HeaderDestination {
  const _HeaderDestination(this.title, this.icon);

  final String title;
  final IconData icon;
}

class _AppHeader extends StatelessWidget {
  const _AppHeader({
    required this.title,
    required this.icon,
    required this.showBackButton,
    required this.onBack,
    required this.showAdminButton,
    required this.onOpenAdmin,
    required this.onOpenSettings,
  });

  final String title;
  final IconData icon;
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
            child: Icon(icon, color: scheme.primary, size: 21),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
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

class _PageContent extends StatelessWidget {
  const _PageContent({
    super.key,
    required this.selectedIndex,
    required this.rentingController,
    required this.onRequestExit,
  });

  final int selectedIndex;
  final RentingDemoController rentingController;
  final ValueChanged<int> onRequestExit;

  @override
  Widget build(BuildContext context) {
    return switch (selectedIndex) {
      0 => HomePage(onNavigate: onRequestExit),
      1 => const ModulePage(
        title: 'Stations',
        subtitle: 'Dock capacity, nearby stations, and return points.',
        icon: Icons.map_rounded,
        accent: Color(0xFFF59E0B),
      ),
      2 => QrScanPage(
        controller: rentingController,
        onRequestExit: () => onRequestExit(0),
      ),
      3 => const ModulePage(
        title: 'Ride history',
        subtitle: 'Review past rides, fares, and return stations.',
        icon: Icons.history_rounded,
        accent: Color(0xFF0369A1),
      ),
      _ => const ModulePage(
        title: 'Profile',
        subtitle: 'Profile, wallet, permissions, and ride history.',
        icon: Icons.person_rounded,
        accent: Color(0xFF7C3AED),
      ),
    };
  }
}

class _AdminManagementPage extends StatelessWidget {
  const _AdminManagementPage({
    super.key,
    required this.onNavigate,
    required this.onOpenBikeManagement,
  });

  final ValueChanged<int> onNavigate;
  final VoidCallback onOpenBikeManagement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          'Admin management',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Manage stations, bikes, and users.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: 12),
        _AdminDestination(
          actionKey: 'admin-stations',
          icon: Icons.map_rounded,
          title: 'Station management',
          subtitle: 'Stations, dock capacity, and return points',
          onTap: () => onNavigate(1),
        ),
        _AdminDestination(
          actionKey: 'admin-bikes',
          icon: Icons.directions_bike_rounded,
          title: 'Bike management',
          subtitle: 'Fleet health, battery status, and maintenance',
          onTap: onOpenBikeManagement,
        ),
        _AdminDestination(
          actionKey: 'admin-users',
          icon: Icons.manage_accounts_rounded,
          title: 'User management',
          subtitle: 'User profile, wallet, permissions, and ride history',
          onTap: () => onNavigate(4),
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

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({super.key, required this.onToggleTheme});

  final ValueChanged<Brightness> onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
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
