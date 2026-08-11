import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

enum AppPage {
  home(routeName: '/home', icon: Icons.home_rounded),
  stations(routeName: '/stations', icon: Icons.map_rounded),
  scan(routeName: '/scan', icon: Icons.qr_code_scanner_rounded),
  history(routeName: '/history', icon: Icons.history_rounded),
  rideDetails(routeName: '/history/details', icon: Icons.receipt_long_rounded),
  profile(routeName: '/profile', icon: Icons.person_rounded),
  admin(routeName: '/admin', icon: Icons.admin_panel_settings_rounded),
  bikeManagement(
    routeName: '/admin/bikes',
    icon: Icons.directions_bike_rounded,
  ),
  settings(routeName: '/settings', icon: Icons.settings_rounded);

  const AppPage({required this.routeName, required this.icon});

  final String routeName;
  final IconData icon;

  String title(AppLocalizations l10n) => switch (this) {
    home => l10n.home,
    stations => l10n.stations,
    scan => l10n.bikeSession,
    history => l10n.history,
    rideDetails => l10n.rideDetails,
    profile => l10n.profile,
    admin => l10n.adminManagement,
    bikeManagement => l10n.bikeManagement,
    settings => l10n.settings,
  };

  String navigationLabel(AppLocalizations l10n) => switch (this) {
    home => l10n.home,
    stations => l10n.stations,
    scan => l10n.scan,
    history => l10n.history,
    profile => l10n.profile,
    _ => throw StateError('$name is not a navigation page'),
  };

  bool get isNavigationRoot => navigationPages.contains(this);

  int? get navigationIndex =>
      isNavigationRoot ? navigationPages.indexOf(this) : null;

  static const navigationPages = [home, stations, scan, history, profile];

  static AppPage? fromRouteName(String? routeName) {
    for (final page in values) {
      if (page.routeName == routeName) return page;
    }
    return null;
  }
}
