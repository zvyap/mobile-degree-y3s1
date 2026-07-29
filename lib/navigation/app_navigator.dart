import 'package:bike_renting_app/features/admin/admin_management_page.dart';
import 'package:bike_renting_app/features/bike/bike_management_page.dart';
import 'package:bike_renting_app/features/home/home_page.dart';
import 'package:bike_renting_app/features/qr/qr_scan_page.dart';
import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/settings/settings_page.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/shared/motion.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class AppNavigator extends StatelessWidget {
  const AppNavigator({
    super.key,
    required this.navigatorKey,
    required this.observer,
    required this.rentingController,
    required this.onSelectRootPage,
    required this.onOpenPage,
    required this.onToggleTheme,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final NavigatorObserver observer;
  final RentingController rentingController;
  final ValueChanged<AppPage> onSelectRootPage;
  final ValueChanged<AppPage> onOpenPage;
  final ValueChanged<Brightness> onToggleTheme;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: AppPage.home.routeName,
      observers: [observer],
      onGenerateRoute: (settings) {
        final page = AppPage.fromRouteName(settings.name) ?? AppPage.home;
        final duration = reduceMotion(context)
            ? Duration.zero
            : const Duration(milliseconds: 260);

        return PageRouteBuilder<void>(
          settings: RouteSettings(name: page.routeName, arguments: page),
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          pageBuilder: (context, animation, secondaryAnimation) =>
              _buildPage(page),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
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
        );
      },
    );
  }

  Widget _buildPage(AppPage page) {
    return switch (page) {
      AppPage.home => HomePage(onNavigate: onSelectRootPage),
      AppPage.stations => const FeaturePlaceholderPage(
        title: 'Stations',
        subtitle: 'Dock capacity, nearby stations, and return points.',
        accent: Color(0xFFF59E0B),
      ),
      AppPage.scan => QrScanPage(
        controller: rentingController,
        onRequestExit: () => onSelectRootPage(AppPage.home),
      ),
      AppPage.history => const FeaturePlaceholderPage(
        title: 'Ride history',
        subtitle: 'Review past rides, fares, and return stations.',
        accent: Color(0xFF0369A1),
      ),
      AppPage.profile => const FeaturePlaceholderPage(
        title: 'Profile',
        subtitle: 'Profile, wallet, permissions, and ride history.',
        accent: Color(0xFF7C3AED),
      ),
      AppPage.admin => AdminManagementPage(
        onNavigate: onSelectRootPage,
        onOpenBikeManagement: () => onOpenPage(AppPage.bikeManagement),
      ),
      AppPage.bikeManagement => const BikeManagementPage(),
      AppPage.settings => SettingsPage(onToggleTheme: onToggleTheme),
    };
  }
}

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver(this.onPageChanged);

  final ValueChanged<AppPage> onPageChanged;

  void _notify(Route<dynamic>? route) {
    final page =
        route?.settings.arguments as AppPage? ??
        AppPage.fromRouteName(route?.settings.name);
    if (page != null) onPageChanged(page);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _notify(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _notify(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _notify(newRoute);
  }
}
