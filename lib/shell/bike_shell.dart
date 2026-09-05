import 'dart:async';

import 'package:bike_renting_app/data/app_repositories.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/features/user/profile_controller.dart';
import 'package:bike_renting_app/navigation/app_navigator.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/navigation/bike_bottom_nav_bar.dart';
import 'package:bike_renting_app/shell/app_header.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BikeShell extends StatefulWidget {
  const BikeShell({super.key, required this.onToggleTheme});

  final ValueChanged<Brightness> onToggleTheme;

  @override
  State<BikeShell> createState() => _BikeShellState();
}

class _BikeShellState extends State<BikeShell> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late final AppNavigatorObserver _navigatorObserver;
  late final RentingController _rentingController;
  late final ProfileController _profileController;
  late final AppLifecycleListener _lifecycleListener;

  AppPage _currentPage = AppPage.home;
  AppPage _selectedRootPage = AppPage.home;

  StreamSubscription<String>? _forceEndSubscription;

  bool get _isAdmin =>
      kDebugMode ||
      _profileController.profile?.role == AppUserRole.admin ||
      _profileController.profile == null;

  @override
  void initState() {
    super.initState();
    final client = Supabase.instance.client;
    final repositories = AppRepositories.fromSupabase(client);
    _rentingController = RentingController(
      repository: repositories.rentals,
      paymentMethodRepository: repositories.paymentMethods,
      debugSource: kDebugMode ? repositories.rentals : null,
      bypassGeofence: kDebugMode,
    );
    unawaited(_rentingController.initialize());
    _forceEndSubscription = _rentingController.onRentalForceEnded.listen((message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showGlobalForceEndAlert(message);
      });
    });
    _profileController = ProfileController(repositories.profiles)
      ..addListener(_handleProfileChanged)
      ..loadProfile();
    _navigatorObserver = AppNavigatorObserver(_handleRouteChanged);
    _lifecycleListener = AppLifecycleListener(
      onPause: _handleAppLifecycleExit,
      onDetach: _handleAppLifecycleExit,
      onHide: _handleAppLifecycleExit,
    );
  }

  Future<void> _showGlobalForceEndAlert(String message) async {
    if (!mounted || _rentingController.isForceEndDialogShowing) return;
    _rentingController.isForceEndDialogShowing = true;
    final dialogContext = _navigatorKey.currentContext ?? context;
    try {
      await showDialog<void>(
        context: dialogContext,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (ctx) {
          final theme = Theme.of(ctx);
          return AlertDialog(
            icon: Icon(
              Icons.warning_amber_rounded,
              size: 44,
              color: theme.colorScheme.error,
            ),
            title: const Text(
              'Session Ended by Admin',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: Text(
              message,
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                key: const ValueKey('rent-force-ended-modal-ok'),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _selectRootPage(AppPage.home);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      _rentingController.isForceEndDialogShowing = false;
    }
  }

  void _handleAppLifecycleExit() {
    _rentingController.handleAppExit();
  }

  void _handleProfileChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _forceEndSubscription?.cancel();
    _lifecycleListener.dispose();
    _profileController.removeListener(_handleProfileChanged);
    _profileController.dispose();
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

    if (_currentPage == AppPage.scan &&
        (_rentingController.stage == RentalStage.bikeCheck ||
            _rentingController.stage == RentalStage.authorizing)) {
      unawaited(_rentingController.cancelReservation());
    }

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

    if (_currentPage == AppPage.scan &&
        (_rentingController.stage == RentalStage.bikeCheck ||
            _rentingController.stage == RentalStage.authorizing)) {
      unawaited(_rentingController.cancelReservation());
    }

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
      return;
    }

    if (!_currentPage.isNavigationRoot) {
      _selectRootPage(AppPage.home);
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
        final canGoBack =
            showBackButton || (_navigatorKey.currentState?.canPop() ?? false);

        return PopScope(
          canPop: !canGoBack,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            _handleBack();
          },
          child: Scaffold(
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
                    userController: _profileController,
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
                  rideActive: _rentingController.isRideActive,
                  onSelected: _selectRootPage,
                ),
          ),
        );
      },
    );
  }
}
