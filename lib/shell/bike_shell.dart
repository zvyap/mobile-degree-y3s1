import 'package:bike_renting_app/data/app_repositories.dart';
import 'package:bike_renting_app/features/renting/rent_demo_auth.dart';
import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/navigation/app_navigator.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/navigation/bike_bottom_nav_bar.dart';
import 'package:bike_renting_app/shell/app_header.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BikeShell extends StatefulWidget {
  const BikeShell({super.key, required this.onToggleTheme});

  final ValueChanged<Brightness> onToggleTheme;

  @override
  State<BikeShell> createState() => _BikeShellState();
}

class _BikeShellState extends State<BikeShell> {
  // TODO: Read this role from the authenticated user session.
  static const bool _isAdmin = true;

  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppNavigatorObserver _navigatorObserver;
  late final RentingController _rentingController;

  AppPage _currentPage = AppPage.home;
  AppPage _selectedRootPage = AppPage.home;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    final repositories = AppRepositories.fromSupabase(client);
    _rentingController = RentingController(
      repository: repositories.rentals,
      authenticator: SupabaseDemoRentAuthenticator(client),
    );
    _navigatorObserver = AppNavigatorObserver(_handleRouteChanged);
  }

  @override
  void dispose() {
    _rentingController.dispose();
    super.dispose();
  }

  void _handleRouteChanged(AppPage page) {
    if (!mounted || page == _currentPage) return;
    setState(() => _currentPage = page);
  }

  void _selectRootPage(AppPage page) {
    assert(page.isNavigationRoot);
    if (!page.isNavigationRoot) return;

    if (_selectedRootPage == page && _currentPage == page) return;

    setState(() => _selectedRootPage = page);
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(
      page.routeName,
      (route) => false,
    );
  }

  void _openPage(AppPage page) {
    if (_currentPage == page) return;
    _navigatorKey.currentState?.pushNamed(page.routeName);
  }

  void _openUtilityPage(AppPage page) {
    if (_currentPage == page) return;

    final navigator = _navigatorKey.currentState;
    if (navigator == null) return;

    navigator.popUntil((route) => route.isFirst);
    navigator.pushNamed(page.routeName);
  }

  void _handleBack() {
    if (_currentPage == AppPage.scan && _rentingController.goBack()) return;

    final navigator = _navigatorKey.currentState;
    if (navigator?.canPop() ?? false) {
      navigator!.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _rentingController,
      builder: (context, child) {
        final showRentalBack =
            _currentPage == AppPage.scan && _rentingController.canGoBack;
        final showBackButton = !_currentPage.isNavigationRoot || showRentalBack;

        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                AppHeader(
                  page: _currentPage,
                  showBackButton: showBackButton,
                  onBack: _handleBack,
                  showAdminButton: _isAdmin,
                  onOpenAdmin: () => _openUtilityPage(AppPage.admin),
                  onOpenSettings: () => _openUtilityPage(AppPage.settings),
                ),
                Expanded(
                  child: AppNavigator(
                    navigatorKey: _navigatorKey,
                    observer: _navigatorObserver,
                    rentingController: _rentingController,
                    onSelectRootPage: _selectRootPage,
                    onOpenPage: _openPage,
                    onToggleTheme: widget.onToggleTheme,
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _rentingController.isFlowLocked
              ? null
              : BikeBottomNavBar(
                  selectedPage: _selectedRootPage,
                  onSelected: _selectRootPage,
                ),
        );
      },
    );
  }
}
