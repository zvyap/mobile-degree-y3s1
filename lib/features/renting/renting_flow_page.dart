import 'package:bike_renting_app/features/renting/renting_controller.dart';
import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/l10n/app_formats.dart';
import 'package:bike_renting_app/l10n/app_localizations.dart';
import 'package:bike_renting_app/l10n/l10n.dart';
import 'package:bike_renting_app/shared/motion.dart';
import 'package:bike_renting_app/shared/ui_components.dart';
import 'package:flutter/material.dart';

class RentingFlowPage extends StatefulWidget {
  const RentingFlowPage({
    super.key,
    this.controller,
    this.onFlowLockChanged,
    this.onRequestExit,
  });

  final RentingController? controller;
  final ValueChanged<bool>? onFlowLockChanged;
  final VoidCallback? onRequestExit;

  @override
  State<RentingFlowPage> createState() => _RentingFlowPageState();
}

class _RentingFlowPageState extends State<RentingFlowPage> {
  late RentingController _controller;
  late bool _ownsController;
  bool _lastLockState = false;

  @override
  void initState() {
    super.initState();
    _attachController(widget.controller);
  }

  @override
  void didUpdateWidget(covariant RentingFlowPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller.removeListener(_handleControllerChange);
      if (_ownsController) _controller.dispose();
      _attachController(widget.controller);
    }
  }

  void _attachController(RentingController? providedController) {
    _ownsController = providedController == null;
    _controller = providedController ?? RentingController();
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
    if (_ownsController) _controller.dispose();
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

class _JourneyHeader extends StatelessWidget {
  const _JourneyHeader({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final step = _journeyStep(controller.stage);
    final labels = [
      context.l10n.scanStep,
      context.l10n.rideStep,
      context.l10n.returnStep,
      context.l10n.payStep,
    ];

    return Padding(
      key: const ValueKey<String>('rent-journey'),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
      child: Row(
        children: [
          for (var index = 0; index < 4; index++) ...[
            Expanded(
              child: _RouteNode(
                label: labels[index],
                icon: const [
                  Icons.qr_code_scanner_rounded,
                  Icons.directions_bike_rounded,
                  Icons.location_on_rounded,
                  Icons.receipt_long_rounded,
                ][index],
                active: index == step,
                complete: index < step,
              ),
            ),
            if (index < 3)
              Expanded(
                child: Container(
                  height: 2,
                  color: index < step
                      ? scheme.secondary
                      : scheme.outline.withValues(alpha: 0.55),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

int _journeyStep(RentalStage stage) {
  return switch (stage) {
    RentalStage.scan || RentalStage.bikeCheck || RentalStage.authorizing => 0,
    RentalStage.unlocking || RentalStage.riding => 1,
    RentalStage.selectingReturn || RentalStage.returning => 2,
    RentalStage.charging || RentalStage.receipt => 3,
  };
}

class _RouteNode extends StatelessWidget {
  const _RouteNode({
    required this.label,
    required this.icon,
    required this.active,
    required this.complete,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final color = active
        ? scheme.primary
        : complete
        ? scheme.secondary
        : scheme.onSurface.withValues(alpha: 0.45);

    return Semantics(
      label: context.l10n.stepSemantics(label),
      selected: active,
      child: Column(
        children: [
          AnimatedContainer(
            duration: motionDuration(context, 180),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: active || complete ? 0.14 : 0.07),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: active ? 2 : 1),
            ),
            child: Icon(
              complete ? Icons.check_rounded : icon,
              size: 18,
              color: color,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.fade,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: active || complete
                  ? FontWeight.w800
                  : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanStage extends StatelessWidget {
  const _ScanStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 0.82,
          child: Semantics(
            button: true,
            label: context.l10n.cameraPreviewSemantics,
            child: GestureDetector(
              key: const ValueKey<String>('rent-camera-preview'),
              behavior: HitTestBehavior.opaque,
              onTap: controller.scanBike,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF111827),
                      scheme.primary.withValues(alpha: 0.30),
                      const Color(0xFF071018),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.46),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.camera_alt_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.l10n.cameraReady,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: SizedBox.square(
                        dimension: 252,
                        child: Stack(
                          children: [
                            for (final alignment in const [
                              Alignment.topLeft,
                              Alignment.topRight,
                              Alignment.bottomLeft,
                              Alignment.bottomRight,
                            ])
                              _ScannerCorner(alignment: alignment),
                            Center(
                              child: Icon(
                                Icons.qr_code_2_rounded,
                                size: 92,
                                color: Colors.white.withValues(alpha: 0.34),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          context.l10n.pointCamera,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (controller.error != null) ...[
          const SizedBox(height: 10),
          _ErrorPanel(message: _rentalError(context, controller)),
        ],
        const SizedBox(height: 8),
        Text(
          context.l10n.scanInstructions,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: scheme.onSurface.withValues(alpha: 0.64),
          ),
        ),
      ],
    );
  }
}

class _BikeCheckStage extends StatelessWidget {
  const _BikeCheckStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final method = controller.selectedPaymentMethod!;

    return Column(
      children: [
        SurfacePanel(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StageTitle(
                icon: Icons.verified_rounded,
                title: context.l10n.bikeReady,
                subtitle: context.l10n.bikeReadyDescription,
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.secondary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconTile(
                      icon: Icons.electric_bike_rounded,
                      color: scheme.secondary,
                      size: 44,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.bike.id,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            context.l10n.bikeBatteryLocation(
                              controller.bike.batteryPercent,
                              _stationName(
                                context.l10n,
                                controller.stations[0],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      key: const ValueKey<String>('rent-bike-view'),
                      style: _secondaryTextButtonStyle(context),
                      onPressed: () {},
                      child: Text(context.l10n.view),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _CheckRow(label: context.l10n.brakesSafe),
              _CheckRow(label: context.l10n.frameSafe),
              _CheckRow(label: context.l10n.lightsSafe),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  key: const ValueKey<String>('rent-report-issue-bike-check'),
                  style: _dangerTextButtonStyle(context),
                  onPressed: () {},
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(context.l10n.reportBikeIssue),
                ),
              ),
              const SizedBox(height: 12),
              const _FareCalculationPanel(),
              const SizedBox(height: 12),
              _PaymentMethodTile(
                method: method,
                trailing: TextButton(
                  style: _secondaryTextButtonStyle(context),
                  onPressed: () => _showPaymentMethods(context, controller),
                  child: Text(context.l10n.change),
                ),
              ),
              const SizedBox(height: 18),
              _ActionButton(
                key: const ValueKey('rent-review-hold'),
                label: context.l10n.reviewHold(
                  context.formats.currency(RentingController.holdAmount),
                ),
                icon: Icons.credit_card_rounded,
                onPressed: controller.reviewAuthorization,
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  key: const ValueKey('rent-cancel'),
                  style: _secondaryTextButtonStyle(context),
                  onPressed: controller.reset,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(context.l10n.cancelRental),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          context.l10n.holdExplanation,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _AuthorizationStage extends StatelessWidget {
  const _AuthorizationStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageTitle(
            icon: Icons.lock_clock_rounded,
            title: context.l10n.authorizeCardHold,
            subtitle: context.l10n.authorizeCardHoldDescription,
          ),
          const SizedBox(height: 14),
          Center(
            child: Column(
              children: [
                Text(
                  context.formats.currency(RentingController.holdAmount),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(context.l10n.temporaryAuthorizationHold),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _PaymentMethodTile(method: controller.selectedPaymentMethod!),
          if (controller.error != null) ...[
            const SizedBox(height: 16),
            _ErrorPanel(message: _rentalError(context, controller)),
          ],
          const SizedBox(height: 14),
          _ActionButton(
            key: const ValueKey('rent-authorize'),
            label: context.l10n.authorizeHold(
              context.formats.currency(RentingController.holdAmount),
            ),
            icon: Icons.verified_user_rounded,
            busy: controller.isBusy,
            onPressed: () => controller.authorizeHold(),
          ),
          const SizedBox(height: 8),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              children: [
                TextButton.icon(
                  style: _secondaryTextButtonStyle(context),
                  onPressed: controller.isBusy
                      ? null
                      : controller.backToBikeCheck,
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: Text(context.l10n.back),
                ),
                TextButton.icon(
                  key: const ValueKey('rent-cancel'),
                  style: _secondaryTextButtonStyle(context),
                  onPressed: controller.isBusy ? null : controller.reset,
                  icon: const Icon(Icons.close_rounded),
                  label: Text(context.l10n.cancelRental),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockStage extends StatelessWidget {
  const _UnlockStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _StageTitle(
            icon: Icons.lock_open_rounded,
            title: context.l10n.unlockBikeTitle,
            subtitle: context.l10n.unlockBikeDescription(controller.bike.id),
          ),
          const SizedBox(height: 18),
          AnimatedContainer(
            duration: motionDuration(context, 220),
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
              border: Border.all(
                color: scheme.primary.withValues(alpha: 0.32),
                width: 2,
              ),
            ),
            child: controller.isBusy
                ? Padding(
                    padding: const EdgeInsets.all(26),
                    child: CircularProgressIndicator(color: scheme.primary),
                  )
                : Icon(
                    Icons.lock_open_rounded,
                    size: 40,
                    color: scheme.primary,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            controller.isBusy
                ? context.l10n.contactingBikeLock
                : context.l10n.cardHoldAuthorized,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (controller.error != null) ...[
            const SizedBox(height: 18),
            _ErrorPanel(message: _rentalError(context, controller)),
          ],
          const SizedBox(height: 16),
          _ActionButton(
            key: const ValueKey('rent-unlock'),
            label: context.l10n.unlockBike,
            icon: Icons.play_arrow_rounded,
            busy: controller.isBusy,
            onPressed: () => controller.unlockBike(),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const ValueKey('rent-cancel'),
            style: _secondaryTextButtonStyle(context),
            onPressed: controller.isBusy ? null : controller.reset,
            icon: const Icon(Icons.close_rounded),
            label: Text(context.l10n.cancelRental),
          ),
        ],
      ),
    );
  }
}

class _RideStage extends StatelessWidget {
  const _RideStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final nearestStation = controller.stations.firstWhere(
      (station) => station.availableDocks > 0,
    );
    final otherNearbyStations = controller.stations
        .where((station) => station.id != nearestStation.id)
        .take(3)
        .toList(growable: false);
    return Column(
      children: [
        SurfacePanel(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StageTitle(
                      icon: Icons.navigation_rounded,
                      title: context.l10n.rideActive,
                      subtitle: context.l10n.rideActiveDescription,
                    ),
                  ),
                  _StatusPill(
                    label: controller.gpsAvailable
                        ? context.l10n.gpsActive
                        : context.l10n.gpsLost,
                    icon: controller.gpsAvailable
                        ? Icons.gps_fixed_rounded
                        : Icons.gps_off_rounded,
                    color: controller.gpsAvailable
                        ? scheme.secondary
                        : scheme.error,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _CityMap(
                routeProgress: (controller.metrics.distanceKm / 2.4).clamp(
                  0,
                  1,
                ),
                selectedStation: null,
                atStation: false,
              ),
              if (controller.error != null) ...[
                const SizedBox(height: 10),
                _ErrorPanel(
                  message: _rentalError(context, controller),
                  actionLabel: context.l10n.restoreGps,
                  onAction: () => controller.setGpsAvailable(true),
                ),
              ],
              const SizedBox(height: 10),
              _MetricGrid(
                children: [
                  _MetricValue(
                    label: context.l10n.time,
                    value: context.formats.duration(
                      controller.metrics.elapsedSeconds,
                    ),
                  ),
                  _MetricValue(
                    label: context.l10n.distance,
                    value: context.l10n.distanceKm(
                      context.formats.decimal(controller.metrics.distanceKm),
                    ),
                  ),
                  _MetricValue(
                    label: context.l10n.estimated,
                    value: context.formats.currency(controller.estimatedFare),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _ActionButton(
                key: const ValueKey('rent-find-station'),
                label: context.l10n.returnBike,
                icon: Icons.assignment_return_rounded,
                onPressed: controller.findReturnStation,
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  key: const ValueKey<String>('rent-report-issue-active'),
                  style: _dangerTextButtonStyle(context),
                  onPressed: () {},
                  icon: const Icon(Icons.report_problem_outlined),
                  label: Text(context.l10n.reportBikeIssue),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          key: const ValueKey<String>('rent-nearest-station'),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: scheme.secondary.withValues(alpha: 0.08),
            border: Border.all(color: scheme.secondary.withValues(alpha: 0.72)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on_rounded, color: scheme.secondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.nearestReturnStation,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.68),
                      ),
                    ),
                    Text(
                      _stationName(context.l10n, nearestStation),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                context.l10n.stationDistance(nearestStation.distanceMeters),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: scheme.secondary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            context.l10n.otherNearbyStations,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 6),
        for (final station in otherNearbyStations) ...[
          _NearbyStationRow(station: station),
          const SizedBox(height: 6),
        ],
        Text(
          context.l10n.phoneSafety,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _NearbyStationRow extends StatelessWidget {
  const _NearbyStationRow({required this.station});

  final ReturnStation station;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final available = station.availableDocks > 0;
    final statusColor = available ? scheme.secondary : scheme.error;

    return Container(
      key: ValueKey<String>('rent-nearby-station-${station.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.36),
        border: Border.all(color: scheme.outline.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            available ? Icons.local_parking_rounded : Icons.block_rounded,
            color: statusColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _stationName(context.l10n, station),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(context.l10n.stationDistance(station.distanceMeters)),
              ],
            ),
          ),
          Text(
            available
                ? context.l10n.dockCount(station.availableDocks)
                : context.l10n.full,
            style: theme.textTheme.labelMedium?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StationStage extends StatelessWidget {
  const _StationStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SurfacePanel(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                tooltip: context.l10n.continueRide,
                onPressed: controller.resumeRide,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _StageTitle(
                  icon: Icons.location_on_rounded,
                  title: context.l10n.chooseReturnStation,
                  subtitle: context.l10n.chooseReturnStationDescription,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _CityMap(
            routeProgress: controller.isAtStation ? 1 : 0.72,
            selectedStation: controller.selectedStation,
            atStation: controller.isAtStation,
          ),
          const SizedBox(height: 10),
          for (final station in controller.stations) ...[
            _StationTile(
              station: station,
              selected: controller.selectedStation?.id == station.id,
              onTap: station.availableDocks == 0
                  ? () => controller.selectStation(station)
                  : () => controller.selectStation(station),
            ),
            const SizedBox(height: 8),
          ],
          if (controller.error != null) ...[
            const SizedBox(height: 4),
            _ErrorPanel(message: _rentalError(context, controller)),
          ],
          if (controller.selectedStation != null) ...[
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const ValueKey('rent-confirm-arrival'),
              onPressed: controller.confirmArrival,
              icon: Icon(
                controller.isAtStation
                    ? Icons.check_rounded
                    : Icons.near_me_rounded,
              ),
              label: Text(
                controller.isAtStation
                    ? context.l10n.withinReturnZone
                    : context.l10n.confirmArrival,
              ),
              style: controller.isAtStation
                  ? OutlinedButton.styleFrom(foregroundColor: scheme.secondary)
                  : null,
            ),
          ],
          const SizedBox(height: 12),
          _ActionButton(
            key: const ValueKey('rent-begin-return'),
            label: context.l10n.continueToDock,
            icon: Icons.keyboard_double_arrow_down_rounded,
            onPressed: controller.beginReturn,
          ),
        ],
      ),
    );
  }
}

class _ReturnStage extends StatelessWidget {
  const _ReturnStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _StageTitle(
            icon: Icons.keyboard_double_arrow_down_rounded,
            title: context.l10n.secureBike,
            subtitle: context.l10n.secureBikeDescription,
          ),
          const SizedBox(height: 18),
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: scheme.secondary.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: controller.isBusy
                ? Padding(
                    padding: const EdgeInsets.all(28),
                    child: CircularProgressIndicator(color: scheme.secondary),
                  )
                : Icon(
                    Icons.pedal_bike_rounded,
                    size: 48,
                    color: scheme.secondary,
                  ),
          ),
          const SizedBox(height: 12),
          Text(
            _stationName(context.l10n, controller.selectedStation!),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            context.l10n.docksAvailable(
              controller.selectedStation!.availableDocks,
            ),
          ),
          if (controller.error != null) ...[
            const SizedBox(height: 18),
            _ErrorPanel(message: _rentalError(context, controller)),
          ],
          const SizedBox(height: 16),
          _ActionButton(
            key: const ValueKey('rent-confirm-dock'),
            label: context.l10n.confirmBikeDocked,
            icon: Icons.lock_rounded,
            busy: controller.isBusy,
            onPressed: () => controller.confirmDock(),
          ),
        ],
      ),
    );
  }
}

class _ChargeStage extends StatelessWidget {
  const _ChargeStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StageTitle(
            icon: Icons.receipt_long_rounded,
            title: context.l10n.rideComplete,
            subtitle: context.l10n.rideCompleteDescription,
          ),
          const SizedBox(height: 14),
          _PriceRow(
            label: context.l10n.unlockFee,
            value: context.formats.currency(RentingController.unlockFee),
          ),
          const SizedBox(height: 10),
          _PriceRow(
            label: context.l10n.startedMinutes(controller.chargedMinutes),
            value: context.formats.currency(
              controller.chargedMinutes * RentingController.perMinuteRate,
            ),
          ),
          const Divider(height: 22),
          _PriceRow(
            label: context.l10n.finalFare,
            value: context.formats.currency(controller.estimatedFare),
            strong: true,
          ),
          const SizedBox(height: 10),
          _PriceRow(
            label: context.l10n.holdReleased,
            value: context.formats.currency(controller.releasedHold),
          ),
          const SizedBox(height: 14),
          _PaymentMethodTile(method: controller.selectedPaymentMethod!),
          const SizedBox(height: 14),
          _ActionButton(
            key: const ValueKey('rent-charge'),
            label: context.l10n.chargeAmount(
              context.formats.currency(controller.estimatedFare),
            ),
            icon: Icons.credit_score_rounded,
            busy: controller.isBusy,
            onPressed: () => controller.capturePayment(),
          ),
        ],
      ),
    );
  }
}

class _ReceiptStage extends StatelessWidget {
  const _ReceiptStage({required this.controller});

  final RentingController controller;

  @override
  Widget build(BuildContext context) {
    final receipt = controller.receipt!;
    final paid = receipt.paymentStatus == PaymentStatus.paid;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final statusColor = paid ? scheme.secondary : scheme.tertiary;

    return SurfacePanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              paid ? Icons.check_rounded : Icons.schedule_rounded,
              size: 34,
              color: statusColor,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            paid ? context.l10n.ridePaid : context.l10n.paymentPending,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            paid
                ? context.l10n.holdReleasedDescription
                : context.l10n.paymentPendingDescription,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _PriceRow(label: context.l10n.rideId, value: receipt.rideId),
                const SizedBox(height: 10),
                _PriceRow(
                  label: context.l10n.duration,
                  value: context.formats.duration(receipt.elapsedSeconds),
                ),
                const SizedBox(height: 10),
                _PriceRow(
                  label: context.l10n.distance,
                  value: context.l10n.distanceKm(
                    context.formats.decimal(receipt.distanceKm),
                  ),
                ),
                const SizedBox(height: 10),
                _PriceRow(
                  label: context.l10n.returnedAt,
                  value: _stationName(context.l10n, receipt.returnStation),
                ),
                const Divider(height: 28),
                _PriceRow(
                  label: context.l10n.finalFare,
                  value: context.formats.currency(receipt.finalFare),
                  strong: true,
                ),
                const SizedBox(height: 10),
                _PriceRow(
                  label: context.l10n.holdReleased,
                  value: context.formats.currency(receipt.releasedHold),
                ),
              ],
            ),
          ),
          if (!paid) ...[
            const SizedBox(height: 18),
            _ActionButton(
              key: const ValueKey('rent-retry-payment'),
              label: context.l10n.retryPayment,
              icon: Icons.refresh_rounded,
              busy: controller.isBusy,
              onPressed: controller.retryPayment,
            ),
          ],
          const SizedBox(height: 18),
          OutlinedButton.icon(
            key: const ValueKey('rent-reset'),
            onPressed: controller.isBusy ? null : controller.reset,
            icon: const Icon(Icons.qr_code_scanner_rounded),
            label: Text(context.l10n.rentAnotherBike),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ],
      ),
    );
  }
}

class _StageTitle extends StatelessWidget {
  const _StageTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconTile(icon: icon, color: scheme.primary, size: 42),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.68),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  const _ScannerCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Align(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: 34,
          height: 34,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: alignment.y < 0
                    ? BorderSide(color: color, width: 4)
                    : BorderSide.none,
                bottom: alignment.y > 0
                    ? BorderSide(color: color, width: 4)
                    : BorderSide.none,
                left: alignment.x < 0
                    ? BorderSide(color: color, width: 4)
                    : BorderSide.none,
                right: alignment.x > 0
                    ? BorderSide(color: color, width: 4)
                    : BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.busy = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        icon: busy
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon),
        label: Text(busy ? context.l10n.pleaseWait : label),
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, this.actionLabel, this.onAction});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: scheme.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded, color: scheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: scheme.onErrorContainer),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: scheme.onErrorContainer,
                ),
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SurfacePanel(
      child: Row(
        children: [
          IconTile(icon: icon, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, size: 21, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _FareCalculationPanel extends StatelessWidget {
  const _FareCalculationPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.tertiary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: scheme.tertiary.withValues(alpha: 0.38)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timer_outlined, color: scheme.tertiary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  context.l10n.timeBasedPricing,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: scheme.surface.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              context.l10n.pricingFormula(
                context.formats.currency(RentingController.unlockFee),
                context.formats.currency(RentingController.perMinuteRate),
              ),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _PriceRow(
            label: context.l10n.pricingExample(10),
            value: context.formats.currency(
              RentingController.unlockFee +
                  (10 * RentingController.perMinuteRate),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.pricingTimerDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.72),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final style = strong
        ? Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)
        : Theme.of(context).textTheme.bodyMedium;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(label, style: style)),
        const SizedBox(width: 12),
        Flexible(
          child: Text(value, textAlign: TextAlign.right, style: style),
        ),
      ],
    );
  }
}

class _PaymentMethodTile extends StatelessWidget {
  const _PaymentMethodTile({required this.method, this.trailing});

  final RentalPaymentMethod method;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.credit_card_rounded, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${method.brand} •••• ${method.lastFour}\n'
              '${_paymentMethodLabel(context.l10n, method)}',
              style: const TextStyle(height: 1.35),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

Future<void> _showPaymentMethods(
  BuildContext context,
  RentingController controller,
) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.choosePaymentMethod,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 14),
              RadioGroup<String>(
                groupValue: controller.selectedPaymentMethod?.id,
                onChanged: (methodId) {
                  if (methodId == null) return;
                  final method = controller.paymentMethods.firstWhere(
                    (candidate) => candidate.id == methodId,
                  );
                  controller.selectPaymentMethod(method);
                  Navigator.pop(context);
                },
                child: Column(
                  children: [
                    for (final method in controller.paymentMethods)
                      RadioListTile<String>(
                        value: method.id,
                        title: Text('${method.brand} •••• ${method.lastFour}'),
                        subtitle: Text(
                          _paymentMethodLabel(context.l10n, method),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _InfoPanel(
                icon: Icons.info_outline_rounded,
                text: context.l10n.addCardFuture,
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300 || textScale > 1.3) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index < children.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        }
        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index < children.length - 1) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _MetricValue extends StatelessWidget {
  const _MetricValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 3),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}

class _StationTile extends StatelessWidget {
  const _StationTile({
    required this.station,
    required this.selected,
    required this.onTap,
  });

  final ReturnStation station;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final available = station.availableDocks > 0;
    final selectable = available && station.id == 'central';
    final highlighted = selected || selectable;
    final selectionLabel = selected
        ? context.l10n.selected
        : selectable
        ? context.l10n.selectable
        : null;
    final badgeColor = available ? scheme.secondary : scheme.error;

    Widget buildBadge(String label, Color color) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Semantics(
      selected: selected,
      button: true,
      enabled: available,
      child: Material(
        color: selected
            ? scheme.secondary.withValues(alpha: 0.09)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          key: ValueKey<String>('rent-station-${station.id}'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(9),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(
                color: highlighted
                    ? scheme.secondary
                    : scheme.outline.withValues(alpha: 0.6),
                width: highlighted ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  available ? Icons.local_parking_rounded : Icons.block_rounded,
                  color: available ? scheme.primary : scheme.error,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _stationName(context.l10n, station),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.l10n.stationDistance(station.distanceMeters),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (selectionLabel != null) ...[
                      buildBadge(selectionLabel, badgeColor),
                      const SizedBox(height: 4),
                    ],
                    buildBadge(
                      available
                          ? context.l10n.dockCount(station.availableDocks)
                          : context.l10n.full,
                      badgeColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CityMap extends StatelessWidget {
  const _CityMap({
    required this.routeProgress,
    required this.selectedStation,
    required this.atStation,
  });

  final double routeProgress;
  final ReturnStation? selectedStation;
  final bool atStation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: context.l10n.cityMapSemantics,
      image: true,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _CityMapPainter(
            background: scheme.surfaceContainerHighest,
            road: scheme.outline.withValues(alpha: 0.65),
            route: scheme.primary,
            station: scheme.secondary,
            rider: scheme.tertiary,
            progress: routeProgress,
            selectedStationId: selectedStation?.id,
            atStation: atStation,
          ),
          child: const SizedBox(width: double.infinity, height: 180),
        ),
      ),
    );
  }
}

class _CityMapPainter extends CustomPainter {
  const _CityMapPainter({
    required this.background,
    required this.road,
    required this.route,
    required this.station,
    required this.rider,
    required this.progress,
    required this.selectedStationId,
    required this.atStation,
  });

  final Color background;
  final Color road;
  final Color route;
  final Color station;
  final Color rider;
  final double progress;
  final String? selectedStationId;
  final bool atStation;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = background);

    final roadPaint = Paint()
      ..color = road
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final y in [0.22, 0.52, 0.82]) {
      canvas.drawLine(
        Offset(0, size.height * y),
        Offset(size.width, size.height * y),
        roadPaint,
      );
    }
    for (final x in [0.18, 0.48, 0.78]) {
      canvas.drawLine(
        Offset(size.width * x, 0),
        Offset(size.width * x, size.height),
        roadPaint,
      );
    }

    final routePath = Path()
      ..moveTo(size.width * 0.08, size.height * 0.80)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.62,
        size.width * 0.34,
        size.height * 0.30,
        size.width * 0.55,
        size.height * 0.48,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.63,
        size.width * 0.80,
        size.height * 0.27,
        size.width * 0.92,
        size.height * 0.18,
      );
    canvas.drawPath(
      routePath,
      Paint()
        ..color = route.withValues(alpha: 0.30)
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      routePath,
      Paint()
        ..color = route
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final metrics = routePath.computeMetrics().first;
    final riderOffset = metrics
        .getTangentForOffset(metrics.length * progress.clamp(0, 1))!
        .position;
    canvas.drawCircle(
      riderOffset,
      12,
      Paint()..color = rider.withValues(alpha: 0.22),
    );
    canvas.drawCircle(riderOffset, 6, Paint()..color = rider);
    canvas.drawCircle(riderOffset, 3, Paint()..color = Colors.white);

    final stationPoints = <String, Offset>{
      'central': Offset(size.width * 0.92, size.height * 0.18),
      'riverside': Offset(size.width * 0.50, size.height * 0.82),
      'market': Offset(size.width * 0.78, size.height * 0.52),
    };
    for (final entry in stationPoints.entries) {
      final selected = entry.key == selectedStationId;
      canvas.drawCircle(
        entry.value,
        selected ? 12 : 9,
        Paint()..color = station.withValues(alpha: selected ? 0.25 : 0.16),
      );
      canvas.drawCircle(
        entry.value,
        selected ? 7 : 5,
        Paint()..color = station,
      );
    }

    if (atStation && selectedStationId != null) {
      final point = stationPoints[selectedStationId];
      if (point != null) {
        canvas.drawCircle(
          point,
          18,
          Paint()
            ..color = station
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CityMapPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedStationId != selectedStationId ||
        oldDelegate.atStation != atStation ||
        oldDelegate.background != background;
  }
}

String _stationName(AppLocalizations l10n, ReturnStation station) {
  return switch (station.id) {
    'central' => l10n.centralStation,
    'riverside' => l10n.riversidePark,
    'market' => l10n.marketSquare,
    'university' => l10n.universityGate,
    _ => station.id,
  };
}

String _paymentMethodLabel(AppLocalizations l10n, RentalPaymentMethod method) {
  return switch (method.id) {
    'visa-4242' => l10n.personalCard,
    'mastercard-4444' => l10n.travelCard,
    _ => method.brand,
  };
}

String _rentalError(BuildContext context, RentingController controller) {
  final l10n = context.l10n;
  return switch (controller.error!) {
    RentalError.invalidQr => l10n.errorInvalidQr,
    RentalError.bikeReserved => l10n.errorBikeReserved(controller.bike.id),
    RentalError.holdDeclined => l10n.errorHoldDeclined(
      context.formats.currency(RentingController.holdAmount),
    ),
    RentalError.lockFailed => l10n.errorLockFailed,
    RentalError.gpsLost => l10n.errorGpsLost,
    RentalError.stationFull => l10n.errorStationFull(
      _stationName(l10n, controller.errorStation!),
    ),
    RentalError.chooseStation => l10n.errorChooseStation,
    RentalError.outsideReturnZone => l10n.errorOutsideReturnZone,
    RentalError.dockNotDetected => l10n.errorDockNotDetected,
  };
}

ButtonStyle _secondaryTextButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return TextButton.styleFrom(
    foregroundColor: scheme.onSurface.withValues(alpha: 0.76),
  );
}

ButtonStyle _dangerTextButtonStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return TextButton.styleFrom(foregroundColor: scheme.error);
}
