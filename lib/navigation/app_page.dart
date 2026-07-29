import 'package:flutter/material.dart';

enum AppPage {
  home(
    routeName: '/home',
    title: 'Home',
    icon: Icons.home_rounded,
    navigationLabel: 'Home',
  ),
  stations(
    routeName: '/stations',
    title: 'Stations',
    icon: Icons.map_rounded,
    navigationLabel: 'Stations',
  ),
  scan(
    routeName: '/scan',
    title: 'Bike Session',
    icon: Icons.qr_code_scanner_rounded,
    navigationLabel: 'Scan',
  ),
  history(
    routeName: '/history',
    title: 'History',
    icon: Icons.history_rounded,
    navigationLabel: 'History',
  ),
  profile(
    routeName: '/profile',
    title: 'Profile',
    icon: Icons.person_rounded,
    navigationLabel: 'Profile',
  ),
  admin(
    routeName: '/admin',
    title: 'Admin management',
    icon: Icons.admin_panel_settings_rounded,
  ),
  bikeManagement(
    routeName: '/admin/bikes',
    title: 'Bike management',
    icon: Icons.directions_bike_rounded,
  ),
  settings(
    routeName: '/settings',
    title: 'Settings',
    icon: Icons.settings_rounded,
  );

  const AppPage({
    required this.routeName,
    required this.title,
    required this.icon,
    this.navigationLabel,
  });

  final String routeName;
  final String title;
  final IconData icon;
  final String? navigationLabel;

  bool get isNavigationRoot => navigationLabel != null;

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
