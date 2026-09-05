import 'dart:async';

import 'dart:io' show Platform;

import 'package:bike_renting_app/bike_station/base_station_map.dart';
import 'package:bike_renting_app/bike_station/shared_map.dart';
import 'package:bike_renting_app/bike_station/station_details.dart';
import 'package:bike_renting_app/bike_station/station_map.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/features/renting/widgets/ride_warning_banner.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/data/paypal/paypal_locale.dart';
import 'package:bike_renting_app/features/renting/paypal_checkout_page.dart';
import 'package:bike_renting_app/data/app_repositories.dart';
import 'package:bike_renting_app/features/legal/privacy_policy_page.dart';
import 'package:bike_renting_app/features/legal/terms_of_service_page.dart';
import 'package:bike_renting_app/features/payment_methods/controllers/payment_methods_controller.dart';
import 'package:bike_renting_app/features/payment_methods/pages/add_edit_card_page.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/shared/motion.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'subpage/journey_header.dart';
part 'subpage/scan_subpage.dart';
part 'subpage/bike_check_subpage.dart';
part 'subpage/authorization_subpage.dart';
part 'subpage/unlock_subpage.dart';
part 'subpage/ride_subpage.dart';
part 'subpage/station_subpage.dart';
part 'subpage/return_subpage.dart';
part 'subpage/charge_subpage.dart';
part 'subpage/receipt_subpage.dart';
part 'subpage/common_components.dart';
part 'subpage/payment_components.dart';
part 'subpage/ride_components.dart';
part 'subpage/station_components.dart';
part 'subpage/renting_helpers.dart';

class RentingFlowPage extends StatefulWidget {
  const RentingFlowPage({
    super.key,
    required this.controller,
    this.onFlowLockChanged,
    this.onRequestExit,
  });

  final RentingController controller;
  final ValueChanged<bool>? onFlowLockChanged;
  final VoidCallback? onRequestExit;

  @override
  State<RentingFlowPage> createState() => _RentingFlowPageState();
}

class _RentingFlowPageState extends State<RentingFlowPage>
    with WidgetsBindingObserver {
  late RentingController _controller;
  bool _lastLockState = false;
  StreamSubscription<void>? _timeoutSubscription;
  StreamSubscription<String>? _forceEndSubscription;
  bool _isTimeoutAlertShowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _attachController(widget.controller);
    _controller.resumeTracking();
    if (_controller.stage == RentalStage.receipt) {
      unawaited(_controller.reset());
    }
    unawaited(_controller.initialize());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _controller.resumeTracking();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _controller.pauseTracking();
        break;
    }
  }

  @override
  void didUpdateWidget(covariant RentingFlowPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.pauseTracking();
      _controller.removeListener(_handleControllerChange);
      _attachController(widget.controller);
      _controller.resumeTracking();
      if (_controller.stage == RentalStage.receipt) {
        unawaited(_controller.reset());
      }
      unawaited(_controller.initialize());
    }
  }

  void _attachController(RentingController providedController) {
    _controller = providedController;
    _lastLockState = _controller.isFlowLocked;
    _controller.addListener(_handleControllerChange);
    _timeoutSubscription?.cancel();
    _timeoutSubscription = _controller.onRentalTimeout.listen((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showTimeoutAlert();
      });
    });
    _forceEndSubscription?.cancel();
    _forceEndSubscription = _controller.onRentalForceEnded.listen((message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showForceEndAlert(message);
      });
    });
  }

  Future<void> _showForceEndAlert(String message) async {
    if (!mounted || _controller.isForceEndDialogShowing) return;
    _controller.isForceEndDialogShowing = true;
    try {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (dialogContext) {
          final theme = Theme.of(dialogContext);
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
                  Navigator.of(dialogContext).pop();
                  widget.onRequestExit?.call();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      _controller.isForceEndDialogShowing = false;
    }
  }

  Future<void> _showTimeoutAlert() async {
    if (!mounted || _isTimeoutAlertShowing) return;
    _isTimeoutAlertShowing = true;
    try {
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        barrierDismissible: false,
        builder: (dialogContext) {
          final theme = Theme.of(dialogContext);
          return AlertDialog(
            icon: Icon(
              Icons.timer_off_rounded,
              size: 44,
              color: theme.colorScheme.error,
            ),
            title: const Text(
              'Rental Timed Out',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'Your bike reservation has timed out because the 10-minute limit was reached. The bike has been released.',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                key: const ValueKey('rent-timeout-modal-ok'),
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } finally {
      _isTimeoutAlertShowing = false;
    }
  }

  void _handleControllerChange() {
    if (!mounted) return;
    final lockState = _controller.isFlowLocked;
    setState(() {});
    if (lockState != _lastLockState) {
      _lastLockState = lockState;
      widget.onFlowLockChanged?.call(lockState);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timeoutSubscription?.cancel();
    _forceEndSubscription?.cancel();
    _controller.removeListener(_handleControllerChange);
    _controller.pauseTracking();
    if (_controller.stage == RentalStage.bikeCheck ||
        _controller.stage == RentalStage.authorizing) {
      unawaited(_controller.cancelReservation());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldReduceMotion = reduceMotion(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_controller.goBack()) {
          if (_controller.stage == RentalStage.bikeCheck ||
              _controller.stage == RentalStage.authorizing) {
            unawaited(_controller.cancelReservation());
          }
          widget.onRequestExit?.call();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalInset = constraints.maxWidth > 920
              ? (constraints.maxWidth - 860) / 2
              : 16.0;
          final scanning = _controller.stage == RentalStage.scan;

          return ListView(
            key: ValueKey<RentalStage>(_controller.stage),
            padding: EdgeInsets.fromLTRB(
              horizontalInset,
              scanning ? 4 : 6,
              horizontalInset,
              96,
            ),
            children: [
              if (_controller.isRideActive &&
                  _controller.activeRideWarning != null) ...[
                RideWarningBanner(
                  key: const ValueKey<String>('ride-session-warning-banner'),
                  warning: _controller.activeRideWarning!,
                ),
                const SizedBox(height: 10),
              ],
              if (!scanning) ...[
                _JourneyHeader(controller: _controller),
                const SizedBox(height: 10),
              ],
              AnimatedSwitcher(
                duration: shouldReduceMotion
                    ? Duration.zero
                    : const Duration(milliseconds: 240),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: KeyedSubtree(
                  key: ValueKey<RentalStage>(_controller.stage),
                  child: _buildStage(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStage() {
    if (!_controller.isInitialized) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(48),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_controller.stage == RentalStage.scan &&
        (_controller.error == RentalError.authenticationFailed ||
            _controller.error == RentalError.connectionFailed)) {
      return SurfacePanel(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 44,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            _ErrorPanel(message: _rentalError(context, _controller)),
            const SizedBox(height: 12),
            _ActionButton(
              label: context.l10n.retry,
              icon: Icons.refresh_rounded,
              busy: _controller.isBusy,
              onPressed: _controller.retryInitialization,
            ),
          ],
        ),
      );
    }

    return switch (_controller.stage) {
      RentalStage.scan => _ScanStage(controller: _controller),
      RentalStage.bikeCheck => _BikeCheckStage(controller: _controller),
      RentalStage.authorizing => _AuthorizationStage(controller: _controller),
      RentalStage.unlocking => _UnlockStage(controller: _controller),
      RentalStage.riding => _RideStage(controller: _controller),
      RentalStage.selectingReturn => _StationStage(controller: _controller),
      RentalStage.returning => _ReturnStage(controller: _controller),
      RentalStage.charging => _ChargeStage(controller: _controller),
      RentalStage.receipt => _ReceiptStage(controller: _controller),
    };
  }
}
