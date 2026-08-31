import 'dart:async';

import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/navigation/app_page.dart';
import 'package:bike_renting_app/shared/motion.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

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

class _RentingFlowPageState extends State<RentingFlowPage> {
  late RentingController _controller;
  bool _lastLockState = false;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
    if (_controller.stage == RentalStage.receipt) {
      unawaited(_controller.reset());
    }
    unawaited(_controller.initialize());
  }

  @override
  void didUpdateWidget(covariant RentingFlowPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleControllerChange);
      _attachController(widget.controller);
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
    _controller.removeListener(_handleControllerChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shouldReduceMotion = reduceMotion(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_controller.goBack()) {
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
              20,
            ),
            children: [
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
