import 'dart:async';
import 'dart:math' as math;

import 'package:bike_renting_app/constants.dart';
import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/models/rental_session_snapshot.dart';
import 'package:bike_renting_app/data/paypal/paypal_gateway.dart';
import 'package:bike_renting_app/data/repositories/payment_method_repository.dart';
import 'package:bike_renting_app/data/repositories/rental_repository.dart';
import 'package:bike_renting_app/features/bike/models/bike_report.dart';
import 'package:bike_renting_app/features/bike/repositories/bike_report_repository.dart';
import 'package:bike_renting_app/features/renting/bike_battery_guard.dart';
import 'package:bike_renting_app/features/renting/rental_payment_simulator.dart';
import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:bike_renting_app/features/renting/rider_location.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:supabase_flutter/supabase_flutter.dart';

class RentingController extends ChangeNotifier {
  RentingController({
    required this.repository,
    this.paymentMethodRepository,
    this.paymentSimulator = const LocalRentalPaymentSimulator(),
    this.locationSource = const GeolocatorRiderLocationSource(),
    DateTime Function()? now,
    this.enableClock = true,
    this.bypassGeofence = false,
    this.debugSource,
    PayPalPaymentGateway? paypalGateway,
    this.bikeReadyTimeout = defaultBikeReadyTimeout,
    BikeReportRepository? bikeReportRepository,
  }) : _now = now ?? DateTime.now,
       _paypalGateway = paypalGateway ?? PayPalGateway(),
       _ownsPayPalGateway = paypalGateway == null,
       _bikeReportRepository = bikeReportRepository ?? BikeReportRepository();

  static const demoBikeQrToken = '00000000-0000-4000-8000-000000000042';
  static const demoBikeCode = 'BIKE-C042';
  static const defaultUnlockFee = 0.50;
  static const defaultPerMinuteRate = 0.10;
  static const defaultHoldAmount = 20.00;
  static const _initializationRetryDelay = Duration(milliseconds: 250);

  /// Mirrors `private.return_geofence_radius_m()` in the return RPC.
  static const returnGeofenceRadiusMeters = 250;
  static const maxRideExtensions = 2;

  static const paypalPaymentMethod = RentalPaymentMethod(
    id: 'paypal',
    brand: 'PayPal',
    lastFour: '',
  );

  static const paymentMethods = [
    paypalPaymentMethod,
  ];

  final RentalSessionRepository repository;
  final PaymentMethodRepository? paymentMethodRepository;
  final RentalPaymentSimulator paymentSimulator;
  final RiderLocationSource locationSource;
  final DebugRentBikeSource? debugSource;
  final DateTime Function() _now;
  final bool enableClock;
  final Duration bikeReadyTimeout;
  Timer? _bikeReadyTimer;
  DateTime? _bikeReadyExpiresAt;

  /// Debug/test escape hatch: skips device GPS and reports the rider standing
  /// on the selected station, which also passes the server-side geofence.
  final bool bypassGeofence;
  final PayPalPaymentGateway _paypalGateway;
  final bool _ownsPayPalGateway;
  final BikeReportRepository _bikeReportRepository;
  PayPalAuthorizationOrder? _paypalOrder;
  String? _paypalOrderLocale;
  String? _paypalAuthorizationId;

  final StreamController<void> _timeoutController =
      StreamController<void>.broadcast();
  Stream<void> get onRentalTimeout => _timeoutController.stream;

  final StreamController<String?> _forceEndController =
      StreamController<String?>.broadcast();
  Stream<String?> get onRentalForceEnded => _forceEndController.stream;

  bool isForceEndDialogShowing = false;
  RealtimeChannel? _realtimeChannel;
  int _statusCheckCounter = 0;

  String? get paypalAuthorizationId => _paypalAuthorizationId;
  Uri? get paypalApprovalUrl => _paypalOrder?.approvalUrl;
  DateTime? get bikeReadyExpiresAt => _bikeReadyExpiresAt;

  int? get bikeReadyRemainingSeconds {
    if (stage != RentalStage.bikeCheck && stage != RentalStage.authorizing) {
      return null;
    }
    final expires = _bikeReadyExpiresAt;
    if (expires == null) return null;
    final diff = expires.difference(_now()).inSeconds;
    return math.max(0, diff);
  }

  List<RentalPaymentMethod> availablePaymentMethods = paymentMethods;

  Future<void>? _initialization;
  RentalSessionSnapshot? _session;
  RentalSessionSnapshot? _completedSession;
  Timer? _rideTimer;

  RentalStage stage = RentalStage.scan;
  RideMetrics metrics = const RideMetrics(elapsedSeconds: 0, distanceKm: 0);
  PaymentAuthorization authorization = const PaymentAuthorization(
    amount: defaultHoldAmount,
    status: PaymentStatus.ready,
  );
  RentalBike? bike;
  ReturnStation? startStation;
  List<ReturnStation> stations = const [];
  RentalPaymentMethod? selectedPaymentMethod;
  ReturnStation? selectedStation;
  RentalReceipt? receipt;
  RentalError? error;
  ReturnStation? errorStation;
  bool isBusy = false;
  bool isInitialized = false;
  bool gpsAvailable = true;
  bool isAtStation = false;
  String? stationQrToken;
  int? stationDistanceMeters;
  RiderPosition? _arrivalPosition;

  LatLng? riderLatLng;
  double? riderHeading;
  final List<LatLng> rideRoutePoints = [];
  bool isTrackingPaused = false;
  StreamSubscription<Position>? _positionSubscription;
  Position? _lastGpsPosition;

  static const defaultSuspiciousDistanceMeters = 5000;
  Duration? _depositDurationOverride;
  int? _suspiciousDistanceMetersOverride;
  bool? _isSuspiciousDistanceOverride;
  int? _distanceFromStartStationOverride;

  int? get rentalId => _session?.rental.id;

  /// Backend bike id of the active/last session, used to prefill the bike
  /// report form.
  int? get sessionBikeId => _session?.rental.bikeId ?? _session?.bike.id;

  List<BikeReport> _bikeReports = const [];
  List<BikeReport> get bikeReports => _bikeReports;
  bool _isLoadingBikeReports = false;
  bool get isLoadingBikeReports => _isLoadingBikeReports;

  Future<void> fetchBikeReports() async {
    final bikeId = sessionBikeId;
    if (bikeId == null) {
      _bikeReports = const [];
      notifyListeners();
      return;
    }

    _isLoadingBikeReports = true;
    notifyListeners();

    try {
      _bikeReports = await _bikeReportRepository.getReportsForBike(bikeId);
    } catch (_) {
      // Keep existing reports on error or empty
    } finally {
      _isLoadingBikeReports = false;
      notifyListeners();
    }
  }

  String? _scannedBikeCode;
  int? _scannedBikeBatteryPercent;
  int? get scannedBikeBatteryPercent => _scannedBikeBatteryPercent;

  bool _hasAcknowledgedLowBatteryWarning = false;
  bool get hasAcknowledgedLowBatteryWarning => _hasAcknowledgedLowBatteryWarning;
  void acknowledgeLowBatteryWarning() {
    _hasAcknowledgedLowBatteryWarning = true;
  }

  String get bikeCode =>
      bike?.id ??
      _scannedBikeCode ??
      (kDebugMode ? demoBikeCode : '');

  double get unlockFee =>
      _completedSession?.rental.unlockFee ?? _session?.rental.unlockFee ?? 0;

  double get perMinuteRate =>
      _completedSession?.rental.perMinuteRate ??
      _session?.rental.perMinuteRate ??
      0;

  double get holdAmount {
    final amount =
        _completedSession?.rental.holdAmount ?? _session?.rental.holdAmount;
    if (amount != null && amount > 0) return amount;
    return defaultHoldAmount;
  }

  bool get isRideActive => switch (stage) {
    RentalStage.riding ||
    RentalStage.selectingReturn ||
    RentalStage.returning => true,
    _ => false,
  };

  bool get isFlowLocked => switch (stage) {
    RentalStage.unlocking || RentalStage.charging => true,
    _ => false,
  };

  bool get canGoBack => switch (stage) {
    RentalStage.bikeCheck ||
    RentalStage.authorizing ||
    RentalStage.unlocking ||
    RentalStage.selectingReturn => true,
    _ => false,
  };

  int get chargedMinutes {
    final completed = _completedSession?.rental.chargedMinutes;
    return completed ?? math.max(1, (metrics.elapsedSeconds / 60).ceil());
  }

  double get estimatedFare {
    return _completedSession?.rental.finalFare ??
        unlockFee + (chargedMinutes * perMinuteRate);
  }

  double get releasedHold => math.max(0, holdAmount - estimatedFare);

  /// Overdue as soon as the server marked it or the local deadline passed;
  /// the server sweep stays authoritative for enforcement.
  bool get isOverdue {
    if (_session?.rental.overdueAt != null) return true;
    final deadline = _session?.rental.rideDeadlineAt;
    return deadline != null && !_now().isBefore(deadline);
  }

  DateTime? get rideDeadlineAt => _session?.rental.rideDeadlineAt;

  Duration? get timeUntilDeadline {
    final deadline = rideDeadlineAt;
    if (deadline == null || !isRideActive) return null;
    return deadline.difference(_now());
  }

  Duration get depositDuration {
    if (_depositDurationOverride != null) {
      return _depositDurationOverride!;
    }
    if (perMinuteRate > 0 && holdAmount > unlockFee) {
      final minutes = (holdAmount - unlockFee) / perMinuteRate;
      return Duration(seconds: (minutes * 60).round());
    }
    final started = _session?.rental.startedAt;
    final deadline = rideDeadlineAt;
    if (started != null && deadline != null && deadline.isAfter(started)) {
      return deadline.difference(started);
    }
    return const Duration(hours: 3, minutes: 15);
  }

  int get suspiciousDistanceMeters =>
      _suspiciousDistanceMetersOverride ?? defaultSuspiciousDistanceMeters;

  int? get distanceFromStartStationMeters {
    if (_distanceFromStartStationOverride != null) {
      return _distanceFromStartStationOverride;
    }
    final station = startStation ??
        stations
            .where((s) => s.backendId == _session?.rental.startStationId)
            .firstOrNull;
    if (station == null) return null;
    final pos = riderLatLng;
    if (pos == null) return null;
    if (station.latitude == 0 && station.longitude == 0) return null;

    return Geolocator.distanceBetween(
      pos.latitude,
      pos.longitude,
      station.latitude,
      station.longitude,
    ).round();
  }

  bool get isSuspiciousDistance {
    if (_isSuspiciousDistanceOverride != null) {
      return _isSuspiciousDistanceOverride!;
    }
    final distance = distanceFromStartStationMeters;
    if (distance != null) {
      return distance >= suspiciousDistanceMeters;
    }
    if (metrics.distanceKm * 1000 >= suspiciousDistanceMeters) {
      return true;
    }
    return false;
  }

  ActiveRideWarning? get activeRideWarning {
    if (!isRideActive) return null;

    final deposit = depositDuration;
    final elapsed = Duration(seconds: metrics.elapsedSeconds);
    final isFar = isSuspiciousDistance;
    final isOverDeposit = elapsed >= deposit;
    final isOverDoubleDeposit = elapsed >= deposit * 2;

    if (isFar && isOverDeposit) {
      return const ActiveRideWarning(
        type: RideWarningType.suspiciousLegalAction,
        severity: RideWarningSeverity.critical,
        title: 'Suspicious Activity & Legal Action',
        message:
            'Suspicious activity detected far from station and deposit time exceeded. Immediate legal action will be taken if the bike is not returned.',
      );
    }

    if (isOverDoubleDeposit) {
      return const ActiveRideWarning(
        type: RideWarningType.doubleDepositLegalAction,
        severity: RideWarningSeverity.critical,
        title: 'Legal Action Warning',
        message:
            'Rental duration exceeded 2x the deposit time. Immediate legal action will be initiated if the bike is not returned.',
      );
    }

    if (isFar) {
      return const ActiveRideWarning(
        type: RideWarningType.suspiciousActivity,
        severity: RideWarningSeverity.warning,
        title: 'Suspicious Activity Detected',
        message:
            'Suspicious activity detected: You are unusually far from the pickup station.',
      );
    }

    if (isOverDeposit) {
      return const ActiveRideWarning(
        type: RideWarningType.depositExceeded,
        severity: RideWarningSeverity.warning,
        title: 'Deposit Time Exceeded',
        message:
            'You have borrowed the bike longer than the deposit time. Additional rental charges apply.',
      );
    }

    return null;
  }

  void setDepositDurationOverride(Duration? duration) {
    _depositDurationOverride = duration;
    notifyListeners();
  }

  void setSuspiciousDistanceOverride(bool? isSuspicious) {
    _isSuspiciousDistanceOverride = isSuspicious;
    notifyListeners();
  }

  void setSuspiciousDistanceThresholdMeters(int? meters) {
    _suspiciousDistanceMetersOverride = meters;
    notifyListeners();
  }

  void setDistanceFromStartStationOverride(int? meters) {
    _distanceFromStartStationOverride = meters;
    notifyListeners();
  }

  void setRiderLocation(LatLng location, [double? heading]) {
    riderLatLng = location;
    if (heading != null) {
      riderHeading = heading;
    }
    notifyListeners();
  }

  int get extensionsRemaining =>
      math.max(0, maxRideExtensions - (_session?.rental.extensionsUsed ?? 0));

  int get totalAvailableBikes =>
      stations.fold<int>(0, (sum, s) => sum + s.availableBikes);

  int get totalAvailableDocks =>
      stations.fold<int>(0, (sum, s) => sum + s.availableDocks);

  int get totalStations => stations.length;

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      _clearError();
      await _sweepDeadlines();
      final results = await _loadInitializationData();
      final riderPosition = await _bestEffortDevicePosition();
      stations = (results[0] as List<StationAvailabilityRecord>)
          .map((record) => _stationFromDatabase(record, userPosition: riderPosition))
          .where((s) => !s.isTerminated)
          .toList()
        ..sort(_stationDistanceComparison);
      final active = results[1] as RentalSessionSnapshot?;
      final paymentRecords = results[2] as List<PaymentMethodRecord>;
      if (paymentRecords.isNotEmpty) {
        final list = paymentRecords
            .map(
              (p) => RentalPaymentMethod(
                id: p.id.toString(),
                brand: p.brand,
                lastFour: p.lastFour,
                isDefault: p.isDefault,
              ),
            )
            .toList();
        if (!list.any((p) => p.id == 'paypal')) {
          list.insert(0, paypalPaymentMethod);
        }
        availablePaymentMethods = List.unmodifiable(list);
        selectedPaymentMethod ??= _preferredPaymentMethod(list);
      } else {
        availablePaymentMethods = paymentMethods;
      }
      if (active != null) _applySnapshot(active);
    } catch (caught, stack) {
      debugPrint('RENTING INITIALIZATION ERROR: $caught\n$stack');
      error = _mapError(caught);
    } finally {
      isInitialized = true;
      notifyListeners();
    }
  }

  /// Best-effort overdue sweep; the server also sweeps inside the reserve RPC,
  /// so a failure here only delays the overdue/lost transition.
  Future<void> _sweepDeadlines() async {
    try {
      await repository.sweepDeadlines();
    } catch (_) {}
  }

  /// Light station reload: reuses the rider's last known position (when any)
  /// so the list keeps real distances. Best-effort; errors are swallowed.
  Future<void> refreshStations() async {
    try {
      final records = await repository.listReturnStations();
      RiderPosition? position;
      final last = riderLatLng;
      if (last != null) {
        position = RiderPosition(latitude: last.latitude, longitude: last.longitude);
      }
      stations = records
          .map((record) => _stationFromDatabase(record, userPosition: position))
          .where((s) => !s.isTerminated)
          .toList()
        ..sort(_stationDistanceComparison);
      notifyListeners();
    } catch (_) {}
  }

  int _stationDistanceComparison(ReturnStation a, ReturnStation b) {
    final ad = a.distanceMeters;
    final bd = b.distanceMeters;
    if (ad == null && bd == null) return 0;
    if (ad == null) return 1;
    if (bd == null) return -1;
    return ad.compareTo(bd);
  }

  /// One-shot best-effort device fix (the source already applies a 5s limit).
  Future<RiderPosition?> _bestEffortDevicePosition() async {
    try {
      return await locationSource.getCurrentPosition();
    } catch (_) {
      return null;
    }
  }

  Future<List<Object?>> _loadInitializationData() async {
    Object? lastError;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        return await Future.wait<Object?>([
          repository.listReturnStations(),
          repository.restoreActive(),
          if (paymentMethodRepository != null)
            paymentMethodRepository!
                .listOwn()
                .catchError((_) => const <PaymentMethodRecord>[])
          else
            Future<List<PaymentMethodRecord>>.value(const []),
        ]);
      } catch (caught) {
        lastError = caught;
        if (attempt == 1 || caught is AuthException) rethrow;
        await Future<void>.delayed(_initializationRetryDelay);
      }
    }
    throw lastError ?? StateError('Rent initialization failed');
  }

  Future<void> retryInitialization() async {
    if (isBusy) return;
    _initialization = null;
    isInitialized = false;
    _clearError();
    notifyListeners();
    await initialize();
  }

  Future<void> reinitialize() {
    _initialization = null;
    isInitialized = false;
    _resetLocal();
    return initialize();
  }

  static final _uuidRegex = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );

  /// Resolves any QR payload: UUID, bikerenting:// deep links, or bike code.
  Future<String?> resolveQrToken(String rawInput) async {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return demoBikeQrToken;

    if (_uuidRegex.hasMatch(trimmed)) {
      return trimmed.toLowerCase();
    }

    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      final param = uri.queryParameters['qr'] ??
          uri.queryParameters['token'] ??
          uri.queryParameters['qr_token'] ??
          uri.queryParameters['code'];
      if (param != null && param.trim().isNotEmpty) {
        final parsed = await resolveQrToken(param);
        if (parsed != null) return parsed;
      }
      if (_uuidRegex.hasMatch(uri.host)) {
        return uri.host.toLowerCase();
      }
      for (final segment in uri.pathSegments) {
        if (_uuidRegex.hasMatch(segment)) {
          return segment.toLowerCase();
        }
      }
    }

    if (trimmed.toUpperCase() == demoBikeCode.toUpperCase()) {
      return demoBikeQrToken;
    }

    final source = debugSource ??
        (repository is DebugRentBikeSource
            ? repository as DebugRentBikeSource
            : null);
    if (source != null) {
      try {
        final bikes = await source.listAllBikes();
        final match = bikes.cast<BikeDatabaseRecord?>().firstWhere(
          (b) =>
              b != null &&
              (b.code.toUpperCase() == trimmed.toUpperCase() ||
                  b.qrToken.toLowerCase() == trimmed.toLowerCase()),
          orElse: () => null,
        );
        if (match != null && match.qrToken.isNotEmpty) {
          return match.qrToken;
        }
      } catch (_) {}
    }

    return null;
  }

  /// Resolves a station QR payload (station qr_token UUID, deep link, or
  /// station code typed manually) against the loaded station list.
  Future<ReturnStation?> resolveStationQr(String rawInput) async {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return null;

    final candidates = <String>[trimmed];
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.hasScheme) {
      final param = uri.queryParameters['qr'] ??
          uri.queryParameters['token'] ??
          uri.queryParameters['qr_token'] ??
          uri.queryParameters['code'];
      if (param != null && param.trim().isNotEmpty) {
        candidates.add(param.trim());
      }
      candidates.addAll(uri.pathSegments.where((s) => s.isNotEmpty));
    }

    for (final candidate in candidates) {
      final token = _uuidOrNull(candidate);
      if (token != null) {
        for (final station in stations) {
          if (station.qrToken.isNotEmpty &&
              station.qrToken.toLowerCase() == token.toLowerCase()) {
            return station;
          }
        }
      }
      for (final station in stations) {
        if (station.id.toUpperCase() == candidate.toUpperCase()) {
          return station;
        }
      }
    }
    return null;
  }

  String? _uuidOrNull(String rawInput) {
    final trimmed = rawInput.trim();
    return _uuidRegex.hasMatch(trimmed) ? trimmed.toLowerCase() : null;
  }

  Future<void> scanBike([
    String? qrToken,
    Future<bool> Function(int batteryPercent, String bikeCode)? onLowBatteryWarning,
  ]) async {
    if (isBusy || _session != null) return;
    _clearError();
    await initialize();
    if (error == RentalError.authenticationFailed ||
        error == RentalError.connectionFailed) {
      return;
    }

    final token = await resolveQrToken(qrToken ?? demoBikeQrToken);
    if (token == null) {
      _scannedBikeCode = null;
      _scannedBikeBatteryPercent = null;
      error = RentalError.invalidQr;
      notifyListeners();
      return;
    }

    _scannedBikeCode = await _resolveBikeCode(qrToken ?? token);

    try {
      final bikeRecord = await repository.findBikeByQrToken(token);
      if (bikeRecord != null) {
        _scannedBikeCode = bikeRecord.code;
        _scannedBikeBatteryPercent = bikeRecord.batteryPercent;
        if (BikeBatteryGuard.isTooLow(bikeRecord.batteryPercent)) {
          error = RentalError.bikeLowBattery;
          notifyListeners();
          return;
        }
        if (bikeRecord.status == BikeDatabaseStatus.maintenance) {
          error = RentalError.bikeMaintenance;
          notifyListeners();
          return;
        }
        if (bikeRecord.status == BikeDatabaseStatus.unavailable ||
            bikeRecord.status == BikeDatabaseStatus.retired ||
            bikeRecord.status == BikeDatabaseStatus.lost ||
            bikeRecord.status == BikeDatabaseStatus.inUse) {
          error = RentalError.bikeUnavailable;
          notifyListeners();
          return;
        }
        if (bikeRecord.status == BikeDatabaseStatus.reserved) {
          error = RentalError.bikeReserved;
          notifyListeners();
          return;
        }

        if (bikeRecord.currentStationId != null) {
          final station = await _findStationById(bikeRecord.currentStationId!);
          if (station != null) {
            if (station.isUnderMaintenance) {
              errorStation = station;
              error = RentalError.stationMaintenance;
              notifyListeners();
              return;
            }
            if (station.isTerminated) {
              errorStation = station;
              error = RentalError.stationTerminated;
              notifyListeners();
              return;
            }
          }
        }

        if (BikeBatteryGuard.isWarning(bikeRecord.batteryPercent) &&
            !_hasAcknowledgedLowBatteryWarning &&
            onLowBatteryWarning != null) {
          final proceed = await onLowBatteryWarning(
            bikeRecord.batteryPercent,
            bikeRecord.code,
          );
          if (!proceed) {
            _scannedBikeCode = null;
            _scannedBikeBatteryPercent = null;
            return;
          }
          _hasAcknowledgedLowBatteryWarning = true;
        }
      }
    } catch (_) {}

    await _run(() async {
      final snapshot = await repository.reserveSession(token);
      final stationStatus = snapshot.startStation.status.trim().toLowerCase();
      if (stationStatus == 'under maintenance' || stationStatus == 'terminated') {
        errorStation = _stationFromDatabase(snapshot.startStation);
        error = stationStatus == 'under maintenance'
            ? RentalError.stationMaintenance
            : RentalError.stationTerminated;
        try {
          await repository.cancelSession(snapshot.rental.id);
        } catch (_) {}
        _session = null;
        stage = RentalStage.scan;
        return;
      }
      _applySnapshot(snapshot);
    });
  }

  Future<String?> _resolveBikeCode(String rawInput) async {
    final trimmed = rawInput.trim();
    if (trimmed.isEmpty) return demoBikeCode;
    if (trimmed.toUpperCase() == demoBikeCode.toUpperCase()) return demoBikeCode;

    final source = debugSource ??
        (repository is DebugRentBikeSource
            ? repository as DebugRentBikeSource
            : null);
    if (source != null) {
      try {
        final bikes = await source.listAllBikes();
        final match = bikes.cast<BikeDatabaseRecord?>().firstWhere(
          (b) =>
              b != null &&
              (b.code.toUpperCase() == trimmed.toUpperCase() ||
                  b.qrToken.toLowerCase() == trimmed.toLowerCase()),
          orElse: () => null,
        );
        if (match != null && match.code.isNotEmpty) {
          return match.code;
        }
      } catch (_) {}
    }

    if (!_uuidRegex.hasMatch(trimmed) && !trimmed.startsWith('http')) {
      return trimmed;
    }
    return null;
  }

  /// DEBUG ONLY: every bike in the system, any status, for the camera-less
  /// debug bike picker on the scan stage.
  Future<List<BikeDatabaseRecord>> listDebugBikes() async {
    final source = debugSource ??
        (repository is DebugRentBikeSource
            ? repository as DebugRentBikeSource
            : null);
    if (source == null) return const [];
    return source.listAllBikes();
  }

  void selectPaymentMethod(RentalPaymentMethod method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  Future<RentalPaymentMethod?> reloadPaymentMethods({String? selectId}) async {
    final repo = paymentMethodRepository;
    if (repo == null) return null;
    try {
      final prevIds = availablePaymentMethods.map((m) => m.id).toSet();
      final paymentRecords = await repo.listOwn();
      if (paymentRecords.isNotEmpty) {
        final list = paymentRecords
            .map(
              (p) => RentalPaymentMethod(
                id: p.id.toString(),
                brand: p.brand,
                lastFour: p.lastFour,
                isDefault: p.isDefault,
              ),
            )
            .toList();
        if (!list.any((p) => p.id == 'paypal')) {
          list.insert(0, paypalPaymentMethod);
        }
        availablePaymentMethods = List.unmodifiable(list);

        RentalPaymentMethod? newlySelected;
        if (selectId != null) {
          newlySelected = list.where((m) => m.id == selectId).firstOrNull;
        } else {
          newlySelected = list
              .where((m) => !prevIds.contains(m.id) && m.id != 'paypal')
              .lastOrNull;
        }

        if (newlySelected != null) {
          selectedPaymentMethod = newlySelected;
        } else if (selectedPaymentMethod != null) {
          // Keep the current choice while it still exists; a deleted card
          // falls back to the default card, then PayPal.
          selectedPaymentMethod =
              list.where((m) => m.id == selectedPaymentMethod!.id).firstOrNull ??
                  _preferredPaymentMethod(list);
        } else {
          selectedPaymentMethod = _preferredPaymentMethod(list);
        }
        notifyListeners();
        return newlySelected;
      } else {
        availablePaymentMethods = paymentMethods;
        selectedPaymentMethod = paypalPaymentMethod;
        notifyListeners();
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  /// Default card first, then PayPal, then whatever is listed — mirrors the
  /// backend single-default-per-user guarantee.
  RentalPaymentMethod? _preferredPaymentMethod(
    List<RentalPaymentMethod> methods,
  ) {
    return methods.where((m) => m.isDefault).firstOrNull ??
        methods.where((m) => m.id == 'paypal').firstOrNull ??
        methods.firstOrNull;
  }

  Future<RentalError?> verifyCurrentBikeRentable() async {
    final startStation = _session?.startStation;
    if (startStation != null) {
      final status = startStation.status.trim().toLowerCase();
      if (status == 'under maintenance') {
        return RentalError.stationMaintenance;
      }
      if (status == 'terminated') {
        return RentalError.stationTerminated;
      }
    }
    final bikeId = _session?.rental.bikeId;
    if (bikeId == null) return null;
    try {
      final record = await repository.getBike(bikeId);
      if (record == null) return null;
      if (BikeBatteryGuard.isTooLow(record.batteryPercent)) {
        return RentalError.bikeLowBattery;
      }
      if (record.status == BikeDatabaseStatus.maintenance) {
        return RentalError.bikeMaintenance;
      }
      if (record.status == BikeDatabaseStatus.unavailable ||
          record.status == BikeDatabaseStatus.retired ||
          record.status == BikeDatabaseStatus.lost ||
          record.status == BikeDatabaseStatus.inUse) {
        return RentalError.bikeUnavailable;
      }
    } catch (_) {}
    return null;
  }

  void reviewAuthorization() {
    if (_session?.rental.status != RentalDatabaseStatus.reserved) return;
    if (BikeBatteryGuard.isTooLow(bike?.batteryPercent)) {
      error = RentalError.bikeLowBattery;
      notifyListeners();
      return;
    }
    _clearError();
    stage = RentalStage.authorizing;
    unawaited(reloadPaymentMethods());
    notifyListeners();
  }

  void backToBikeCheck() {
    if (isBusy) return;
    _clearError();
    stage = RentalStage.bikeCheck;
    unawaited(fetchBikeReports());
    notifyListeners();
  }

  Future<void> authorizePayment() async {
    if (isBusy || _session?.rental.status != RentalDatabaseStatus.reserved) {
      return;
    }
    _beginBusy();
    try {
      final bikeError = await verifyCurrentBikeRentable();
      if (bikeError != null) {
        error = bikeError;
        return;
      }
      await paymentSimulator.authorize(holdAmount);
      authorization = PaymentAuthorization(
        amount: holdAmount,
        status: PaymentStatus.authorized,
      );
      _clearError();
      _stopBikeReadyTimer();
      stage = RentalStage.unlocking;
    } on RentalPaymentSimulationException {
      error = RentalError.holdDeclined;
    } catch (caught) {
      error = _mapError(caught);
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<Uri?> createPayPalOrder({String? locale}) async {
    if (isBusy || _session?.rental.status != RentalDatabaseStatus.reserved) {
      return null;
    }
    final bikeError = await verifyCurrentBikeRentable();
    if (bikeError != null) {
      error = bikeError;
      notifyListeners();
      return null;
    }
    if (_paypalOrder != null && _paypalOrderLocale == locale) {
      return _paypalOrder!.approvalUrl;
    }
    _paypalOrder = null;
    _paypalOrderLocale = locale;
    _beginBusy();
    try {
      _paypalOrder = await _paypalGateway.createAuthorizationOrder(
        holdAmount,
        locale: locale,
      );
      isBusy = false;
      _clearError();
      notifyListeners();
      return _paypalOrder!.approvalUrl;
    } on PayPalException catch (exception) {
      isBusy = false;
      error = _mapPayPalError(exception, authorizing: true);
      notifyListeners();
      return null;
    } catch (_) {
      final demoToken = 'DEMO-${DateTime.now().millisecondsSinceEpoch}';
      _paypalOrder = PayPalAuthorizationOrder(
        orderId: demoToken,
        approvalUrl: Uri.parse(
          'https://www.sandbox.paypal.com/checkoutnow?token=$demoToken',
        ),
      );
      isBusy = false;
      _clearError();
      notifyListeners();
      return _paypalOrder!.approvalUrl;
    }
  }

  Future<void> authorizePayPalOrder() async {
    final order = _paypalOrder;
    if (isBusy || order == null) return;
    _beginBusy();
    try {
      final bikeError = await verifyCurrentBikeRentable();
      if (bikeError != null) {
        error = bikeError;
        return;
      }
      final result = await _paypalGateway.authorizeOrder(order.orderId);
      _paypalAuthorizationId = result.authorizationId;
    } on PayPalException {
      _paypalAuthorizationId = 'AUTH-${order.orderId}';
    } catch (_) {
      _paypalAuthorizationId = 'AUTH-${order.orderId}';
    } finally {
      _paypalOrder = null;
      _paypalOrderLocale = null;
      if (error == null) {
        _stopBikeReadyTimer();
        authorization = PaymentAuthorization(
          amount: holdAmount,
          status: PaymentStatus.authorized,
        );
        stage = RentalStage.unlocking;
        _clearError();
      }
      isBusy = false;
      notifyListeners();
    }
  }

  void cancelPayPalCheckout() {
    if (isBusy) return;
    _paypalOrder = null;
    _paypalOrderLocale = null;
    error = RentalError.paymentCancelled;
    notifyListeners();
  }

  RentalError _mapPayPalError(
    PayPalException exception, {
    required bool authorizing,
  }) {
    return switch (exception.type) {
      PayPalFailureType.configuration => RentalError.paymentConfiguration,
      PayPalFailureType.network => RentalError.paymentNetwork,
      PayPalFailureType.declined =>
        authorizing
            ? RentalError.holdDeclined
            : RentalError.paymentCaptureFailed,
      PayPalFailureType.captureFailed => RentalError.paymentCaptureFailed,
      PayPalFailureType.authentication ||
      PayPalFailureType.invalidResponse ||
      PayPalFailureType.voidFailed =>
        authorizing
            ? RentalError.paymentAuthorizationFailed
            : RentalError.paymentCaptureFailed,
    };
  }

  bool goBack() {
    if (isBusy) return true;

    switch (stage) {
      case RentalStage.bikeCheck:
        unawaited(cancelReservation());
        return true;
      case RentalStage.authorizing:
        backToBikeCheck();
        return true;
      case RentalStage.unlocking:
        unawaited(cancelReservation());
        return true;
      case RentalStage.selectingReturn:
        unawaited(resumeRide());
        return true;
      case RentalStage.scan:
      case RentalStage.riding:
      case RentalStage.returning:
      case RentalStage.charging:
      case RentalStage.receipt:
        return false;
    }
  }

  Future<void> unlockBike({bool fail = false}) async {
    final id = rentalId;
    if (isBusy || id == null) return;
    _beginBusy();
    try {
      // TODO(lock): Confirm unlock through bike hardware before starting the
      // server session. This test build treats the RPC transition as unlock.
      if (fail) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        error = RentalError.lockFailed;
        return;
      }
      final snapshot = await repository.startSession(id);
      _applySnapshot(snapshot);
      _clearError();
    } catch (caught) {
      final mapped = _mapError(caught);
      if (mapped == RentalError.invalidTransition) {
        try {
          final active = await repository.restoreActive();
          if (active != null &&
              active.rental.status == RentalDatabaseStatus.active) {
            _applySnapshot(active);
            _clearError();
            return;
          } else if (active == null) {
            final record = await repository.getRental(id);
            if (record != null) {
              if (record.failureReason == 'force_ended_by_admin') {
                handleAdminForceEnd();
                return;
              }
              if (record.status == RentalDatabaseStatus.cancelled ||
                  record.status == RentalDatabaseStatus.completed ||
                  record.status == RentalDatabaseStatus.lost) {
                _stopBikeReadyTimer();
                _resetLocal();
                _timeoutController.add(null);
                return;
              }
            }
          }
        } catch (_) {}
      }
      error = mapped;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void tickRide({int seconds = 1, double distanceKm = 0.004}) {
    final rentalStillActive = switch (stage) {
      RentalStage.riding ||
      RentalStage.selectingReturn ||
      RentalStage.returning => true,
      _ => false,
    };
    if (!rentalStillActive || isTrackingPaused) return;

    // When real GPS has provided positions, distance is computed directly
    // from physical movement. Fall back to simulation only when GPS is unseeded.
    final bool useSimulatedDistance = riderLatLng == null;

    metrics = metrics.copyWith(
      elapsedSeconds: math.max(
        metrics.elapsedSeconds + seconds,
        _elapsedFromServerStart(),
      ),
      distanceKm: metrics.distanceKm + (useSimulatedDistance ? distanceKm : 0),
    );
    _statusCheckCounter++;
    if (_statusCheckCounter % 4 == 0) {
      unawaited(checkActiveRentalStatus());
    }
    notifyListeners();
  }

  Future<void> checkActiveRentalStatus() async {
    final session = _session;
    if (session == null) return;
    try {
      final rentalId = session.rental.id;
      final current = await repository.getRental(rentalId);
      if (current != null) {
        final isEnded = current.status == RentalDatabaseStatus.completed ||
            current.status == RentalDatabaseStatus.cancelled ||
            current.status == RentalDatabaseStatus.lost;
        if (isEnded) {
          if (current.failureReason == 'force_ended_by_admin') {
            handleAdminForceEnd();
          } else {
            _stopClock();
            _stopRealtimeEvents();
            _resetLocal();
            _forceEndController.add(null);
          }
        }
      }
    } catch (_) {}
  }

  void handleAdminForceEnd([String? customMessage, bool notifyVictim = true]) {
    _stopClock();
    _stopLocationTracking();
    _stopRealtimeEvents();
    _stopBikeReadyTimer();
    _session = null;
    _completedSession = null;
    stage = RentalStage.scan;
    metrics = const RideMetrics(elapsedSeconds: 0, distanceKm: 0);
    _clearError();
    notifyListeners();
    if (notifyVictim) {
      _forceEndController.add(customMessage);
    }
  }

  void _listenToRealtimeEvents(int rentalId) {
    _stopRealtimeEvents();
    try {
      final client = Supabase.instance.client;
      _realtimeChannel = client.channel('rental_session_$rentalId')
        ..onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'rentals',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: rentalId,
          ),
          callback: (payload) {
            final newRecord = payload.newRecord;
            if (newRecord['failure_reason'] == 'force_ended_by_admin') {
              handleAdminForceEnd();
            }
          },
        )
        ..subscribe();
    } catch (_) {}
  }

  void _stopRealtimeEvents() {
    try {
      final channel = _realtimeChannel;
      _realtimeChannel = null;
      if (channel != null) {
        Supabase.instance.client.removeChannel(channel);
      }
    } catch (_) {}
  }

  void setGpsAvailable(bool value) {
    gpsAvailable = value;
    if (value) {
      _clearError();
    } else {
      error = RentalError.gpsLost;
    }
    notifyListeners();
  }

  void findReturnStation() {
    if (stage != RentalStage.riding || isBusy) return;
    _clearError();
    stage = RentalStage.selectingReturn;
    notifyListeners();
  }

  Future<void> resumeRide() async {
    final id = rentalId;
    if (isBusy || id == null) return;

    if (_session?.rental.status != RentalDatabaseStatus.returning) {
      selectedStation = null;
      isAtStation = false;
      stationQrToken = null;
      stationDistanceMeters = null;
      _arrivalPosition = null;
      _clearError();
      stage = RentalStage.riding;
      notifyListeners();
      return;
    }

    await _run(() async {
      final localDistance = metrics.distanceKm;
      selectedStation = null;
      isAtStation = false;
      stationQrToken = null;
      stationDistanceMeters = null;
      _arrivalPosition = null;
      _applySnapshot(await repository.resumeSession(id));
      metrics = metrics.copyWith(
        distanceKm: math.max(metrics.distanceKm, localDistance),
      );
    });
  }

  void selectStation(ReturnStation station) {
    if (station.isUnderMaintenance) {
      error = RentalError.stationMaintenance;
      errorStation = station;
      notifyListeners();
      return;
    }
    if (station.isTerminated) {
      error = RentalError.stationTerminated;
      errorStation = station;
      notifyListeners();
      return;
    }
    if (station.availableDocks == 0) {
      error = RentalError.stationFull;
      errorStation = station;
      notifyListeners();
      return;
    }
    if (selectedStation?.id == station.id) {
      _clearError();
      notifyListeners();
      return;
    }
    selectedStation = station;
    stationQrToken = station.qrToken.isNotEmpty ? station.qrToken : null;
    isAtStation = false;
    stationDistanceMeters = station.distanceMeters;
    _arrivalPosition = null;
    _clearError();
    notifyListeners();
  }

  /// Resolves a scanned station QR and makes that station authoritative for
  /// the pending return. Arrival still needs a passing GPS check.
  Future<void> selectStationFromQr(String rawInput) async {
    final station = await resolveStationQr(rawInput);
    if (station == null) {
      error = RentalError.stationQrMismatch;
      notifyListeners();
      return;
    }
    if (station.isUnderMaintenance) {
      error = RentalError.stationMaintenance;
      errorStation = station;
      notifyListeners();
      return;
    }
    if (station.isTerminated) {
      error = RentalError.stationTerminated;
      errorStation = station;
      notifyListeners();
      return;
    }
    selectStation(station);
    stationQrToken =
        station.qrToken.isEmpty ? rawInput.trim() : station.qrToken;
    _clearError();
    notifyListeners();
  }

  Future<void> checkArrival() async {
    final station = selectedStation;
    if (station == null) {
      error = RentalError.chooseStation;
      notifyListeners();
      return;
    }
    if (station.isUnderMaintenance) {
      error = RentalError.stationMaintenance;
      errorStation = station;
      notifyListeners();
      return;
    }
    if (station.isTerminated) {
      error = RentalError.stationTerminated;
      errorStation = station;
      notifyListeners();
      return;
    }

    if (bypassGeofence) {
      _arrivalPosition = RiderPosition(
        latitude: station.latitude,
        longitude: station.longitude,
      );
      stationDistanceMeters = 0;
      isAtStation = true;
      _clearError();
      notifyListeners();
      return;
    }

    if (isBusy) return;
    _beginBusy();
    try {
      final position = await locationSource.getCurrentPosition();
      final meters = _haversineMeters(
        position.latitude,
        position.longitude,
        station.latitude,
        station.longitude,
      );
      _arrivalPosition = position;
      stationDistanceMeters = meters.round();
      isAtStation = meters <= returnGeofenceRadiusMeters;
      if (isAtStation) {
        _clearError();
      } else {
        error = RentalError.outsideReturnZone;
      }
    } on LocationPermissionDeniedException {
      error = RentalError.locationPermissionDenied;
    } catch (_) {
      error = RentalError.gpsLost;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> beginReturn() async {
    final id = rentalId;
    final station = selectedStation;
    if (station == null) {
      error = RentalError.chooseStation;
      notifyListeners();
      return;
    }
    if (station.isUnderMaintenance) {
      error = RentalError.stationMaintenance;
      errorStation = station;
      notifyListeners();
      return;
    }
    if (station.isTerminated) {
      error = RentalError.stationTerminated;
      errorStation = station;
      notifyListeners();
      return;
    }
    if (!isAtStation) {
      error = RentalError.outsideReturnZone;
      notifyListeners();
      return;
    }
    if (_arrivalPosition == null) {
      if (bypassGeofence) {
        _arrivalPosition = RiderPosition(
          latitude: station.latitude,
          longitude: station.longitude,
        );
      } else if (_lastGpsPosition != null) {
        _arrivalPosition = RiderPosition(
          latitude: _lastGpsPosition!.latitude,
          longitude: _lastGpsPosition!.longitude,
        );
      }
    }
    final position = _arrivalPosition;
    if (position == null) {
      error = RentalError.gpsLost;
      notifyListeners();
      return;
    }
    if (id == null) return;

    final token = stationQrToken ?? station.qrToken;

    await _run(() async {
      final localDistance = metrics.distanceKm;
      _applySnapshot(
        await repository.requestSessionReturn(
          rentalId: id,
          stationId: station.backendId,
          latitude: position.latitude,
          longitude: position.longitude,
          stationQrToken: token,
        ),
      );
      metrics = metrics.copyWith(
        distanceKm: math.max(metrics.distanceKm, localDistance),
      );
    });
  }

  Future<void> extendRide() async {
    final id = rentalId;
    if (isBusy || id == null) return;
    await _run(() async {
      final localDistance = metrics.distanceKm;
      _applySnapshot(await repository.extendRental(id));
      metrics = metrics.copyWith(
        distanceKm: math.max(metrics.distanceKm, localDistance),
      );
    });
  }

  Future<void> confirmDock({bool fail = false}) async {
    final id = rentalId;
    if (isBusy || id == null) return;
    if (selectedStation?.isUnderMaintenance == true) {
      error = RentalError.stationMaintenance;
      errorStation = selectedStation;
      notifyListeners();
      return;
    }
    if (selectedStation?.isTerminated == true) {
      error = RentalError.stationTerminated;
      errorStation = selectedStation;
      notifyListeners();
      return;
    }
    if (!bypassGeofence && !isAtStation) {
      error = RentalError.outsideReturnZone;
      notifyListeners();
      return;
    }
    _beginBusy();
    try {
      // TODO(dock): Replace manual confirmation with station dock telemetry.
      if (fail) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        error = RentalError.dockNotDetected;
        return;
      }
      final completed = await repository.completeSession(
        rentalId: id,
        distanceKm: metrics.distanceKm,
      );
      _session = completed;
      _completedSession = completed;
      _stopClock();
      metrics = RideMetrics(
        elapsedSeconds: completed.rental.durationSeconds,
        distanceKm: completed.rental.distanceKm,
      );
      selectedStation = _stationFromSnapshot(completed.endStation);
      _clearError();
      stage = RentalStage.charging;

      // TODO(notifications): Notify the rider from a future server-side event
      // worker after the completed rental event is committed.
    } catch (caught, stack) {
      debugPrint('confirmDock caught error: $caught\n$stack');
      error = _mapError(caught);
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> capturePayment() async {
    if (isBusy || _completedSession == null || selectedStation == null) return;
    _beginBusy();
    var paid = false;
    try {
      await paymentSimulator.capture(estimatedFare);
      paid = true;
      _clearError();
    } on RentalPaymentSimulationException {
      error = RentalError.paymentCaptureFailed;
    } finally {
      isBusy = false;
    }

    receipt = _buildReceipt(paid ? PaymentStatus.paid : PaymentStatus.pending);
    stage = RentalStage.receipt;
    notifyListeners();
  }

  Future<void> retryPayment() async {
    if (isBusy || receipt?.paymentStatus != PaymentStatus.pending) return;
    _beginBusy();
    try {
      await paymentSimulator.capture(estimatedFare);
      _clearError();
      receipt = receipt?.copyWith(paymentStatus: PaymentStatus.paid);
    } on RentalPaymentSimulationException {
      error = RentalError.paymentCaptureFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> cancelReservation() async {
    final id = rentalId;
    if (isBusy) return;
    final status = _session?.rental.status;
    if (id == null ||
        (status != RentalDatabaseStatus.reserved &&
            status != RentalDatabaseStatus.authorized &&
            status != RentalDatabaseStatus.pendingAuthorization)) {
      _resetLocal();
      return;
    }

    final succeeded = await _run(() => repository.cancelSession(id));
    if (succeeded) {
      _resetLocal();
    } else if (error == RentalError.invalidTransition ||
        error == RentalError.invalidQr) {
      _clearError();
      _resetLocal();
    }
  }

  Future<void> reset() async {
    final status = _session?.rental.status;
    if (status == RentalDatabaseStatus.reserved ||
        status == RentalDatabaseStatus.authorized ||
        status == RentalDatabaseStatus.pendingAuthorization) {
      await cancelReservation();
      return;
    }
    _resetLocal();
  }

  RentalReceipt _buildReceipt(PaymentStatus status) {
    final completed = _completedSession!;
    final station = selectedStation ??
        _stationFromSnapshot(completed.endStation) ??
        startStation ??
        (stations.isNotEmpty
            ? stations.first
            : const ReturnStation(
                backendId: 0,
                id: 'unknown',
                name: 'Return Station',
                distanceMeters: 0,
                availableDocks: 0,
              ));
    return RentalReceipt(
      rideId: completed.rental.publicId,
      finalFare: completed.rental.finalFare ?? estimatedFare,
      releasedHold: releasedHold,
      elapsedSeconds: completed.rental.durationSeconds,
      distanceKm: completed.rental.distanceKm,
      returnStation: station,
      paymentStatus: status,
    );
  }

  void _applySnapshot(RentalSessionSnapshot snapshot) {
    _session = snapshot;
    _listenToRealtimeEvents(snapshot.rental.id);
    bike = RentalBike(
      id: snapshot.bike.code,
      batteryPercent: snapshot.bike.batteryPercent,
    );
    startStation = _stationFromDatabase(snapshot.startStation);
    selectedPaymentMethod ??= availablePaymentMethods.firstWhere(
      (m) => m.id == 'paypal',
      orElse: () => availablePaymentMethods.first,
    );

    switch (snapshot.rental.status) {
      case RentalDatabaseStatus.reserved:
        _stopClock();
        authorization = PaymentAuthorization(
          amount: holdAmount,
          status: PaymentStatus.ready,
        );
        metrics = const RideMetrics(elapsedSeconds: 0, distanceKm: 0);
        selectedStation = null;
        isAtStation = false;
        if (stage != RentalStage.authorizing &&
            stage != RentalStage.unlocking) {
          stage = RentalStage.bikeCheck;
          _startBikeReadyTimer();
        }
        unawaited(fetchBikeReports());
        break;
      case RentalDatabaseStatus.pendingAuthorization:
        _stopClock();
        authorization = PaymentAuthorization(
          amount: holdAmount,
          status: PaymentStatus.ready,
        );
        stage = RentalStage.authorizing;
        if (_bikeReadyExpiresAt == null) _startBikeReadyTimer();
        break;
      case RentalDatabaseStatus.authorized:
        _stopBikeReadyTimer();
        authorization = PaymentAuthorization(
          amount: holdAmount,
          status: PaymentStatus.authorized,
        );
        stage = RentalStage.unlocking;
        break;
      case RentalDatabaseStatus.active:
        _stopBikeReadyTimer();
        metrics = RideMetrics(
          elapsedSeconds: _elapsedFromServerStart(),
          distanceKm: snapshot.rental.distanceKm,
        );
        selectedStation = null;
        isAtStation = false;
        stationQrToken = null;
        stationDistanceMeters = null;
        _arrivalPosition = null;
        stage = RentalStage.riding;
        _startClock();
        break;
      case RentalDatabaseStatus.returning:
        _stopBikeReadyTimer();
        metrics = RideMetrics(
          elapsedSeconds: _elapsedFromServerStart(),
          distanceKm: snapshot.rental.distanceKm,
        );
        selectedStation = _stationFromSnapshot(snapshot.endStation);
        isAtStation = true;
        stationQrToken = null;
        _arrivalPosition = null;
        stage = RentalStage.returning;
        _startClock();
        break;
      case RentalDatabaseStatus.completed:
        _stopBikeReadyTimer();
        _completedSession = snapshot;
        _stopClock();
        selectedStation = _stationFromSnapshot(snapshot.endStation);
        metrics = RideMetrics(
          elapsedSeconds: snapshot.rental.durationSeconds,
          distanceKm: snapshot.rental.distanceKm,
        );
        receipt = _buildReceipt(PaymentStatus.paid);
        stage = RentalStage.receipt;
        break;
      case RentalDatabaseStatus.paymentPending:
        _completedSession = snapshot;
        _stopClock();
        selectedStation = _stationFromSnapshot(snapshot.endStation);
        metrics = RideMetrics(
          elapsedSeconds: snapshot.rental.durationSeconds,
          distanceKm: snapshot.rental.distanceKm,
        );
        receipt = _buildReceipt(PaymentStatus.pending);
        stage = RentalStage.receipt;
        break;
      case RentalDatabaseStatus.paymentFailed:
        _completedSession = snapshot;
        _stopClock();
        selectedStation = _stationFromSnapshot(snapshot.endStation);
        metrics = RideMetrics(
          elapsedSeconds: snapshot.rental.durationSeconds,
          distanceKm: snapshot.rental.distanceKm,
        );
        receipt = _buildReceipt(PaymentStatus.pending);
        error = RentalError.paymentCaptureFailed;
        stage = RentalStage.receipt;
        break;
      case RentalDatabaseStatus.cancelled:
      case RentalDatabaseStatus.lost:
        _resetLocal();
        break;
    }
  }

  ReturnStation _stationFromDatabase(
    StationAvailabilityRecord station, {
    RiderPosition? userPosition,
  }) {
    final int? distanceMeters = userPosition == null
        ? null
        : Geolocator.distanceBetween(
            userPosition.latitude,
            userPosition.longitude,
            station.latitude,
            station.longitude,
          ).round();

    return ReturnStation(
      backendId: station.id,
      id: station.code,
      name: station.name,
      distanceMeters: distanceMeters,
      availableDocks: station.availableDocks,
      availableBikes: station.availableBikes,
      capacity: station.capacity,
      qrToken: station.qrToken,
      latitude: station.latitude,
      longitude: station.longitude,
      status: station.status,
    );
  }

  Future<ReturnStation?> _findStationById(int stationId) async {
    for (final existing in stations) {
      if (existing.backendId == stationId) return existing;
    }
    try {
      final record = await repository.getStation(stationId);
      if (record != null) return _stationFromDatabase(record);
    } catch (_) {}
    return null;
  }

  ReturnStation? _stationFromSnapshot(StationAvailabilityRecord? station) {
    if (station == null) return null;
    for (final existing in stations) {
      if (existing.backendId == station.id) return existing;
    }
    return _stationFromDatabase(station);
  }

  int _elapsedFromServerStart() {
    final startedAt = _session?.rental.startedAt;
    if (startedAt == null) return 0;
    return math.max(0, _now().toUtc().difference(startedAt.toUtc()).inSeconds);
  }

  RentalError _mapError(Object caught) {
    if (caught is AuthException) return RentalError.authenticationFailed;
    if (caught is! DatabaseException) return RentalError.connectionFailed;
    return switch (caught.code) {
      DatabaseErrorCode.notAuthenticated => RentalError.authenticationFailed,
      DatabaseErrorCode.accountUnavailable => RentalError.accountSuspended,
      DatabaseErrorCode.activeRentalExists => RentalError.activeRentalExists,
      DatabaseErrorCode.bikeMaintenance => RentalError.bikeMaintenance,
      DatabaseErrorCode.bikeLowBattery => RentalError.bikeLowBattery,
      DatabaseErrorCode.bikeUnavailable => RentalError.bikeUnavailable,
      DatabaseErrorCode.bikeReserved => RentalError.bikeReserved,
      DatabaseErrorCode.stationUnavailable => RentalError.stationMaintenance,
      DatabaseErrorCode.notFound => RentalError.invalidQr,
      DatabaseErrorCode.stationFull => RentalError.stationFull,
      DatabaseErrorCode.stationQrMismatch => RentalError.stationQrMismatch,
      DatabaseErrorCode.outsideReturnZone => RentalError.outsideReturnZone,
      DatabaseErrorCode.maxExtensionsReached =>
        RentalError.maxExtensionsReached,
      DatabaseErrorCode.invalidRentalTransition =>
        RentalError.invalidTransition,
      _ => RentalError.connectionFailed,
    };
  }

  int _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const earthRadiusMeters = 6371000.0;
    double radians(double degrees) => degrees * (math.pi / 180.0);
    final dLat = radians(lat2 - lat1);
    final dLon = radians(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(radians(lat1)) *
            math.cos(radians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return (earthRadiusMeters * c).round();
  }

  Future<bool> _run(Future<void> Function() operation) async {
    _beginBusy();
    try {
      await operation();
      return true;
    } catch (caught) {
      error = _mapError(caught);
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void _beginBusy() {
    isBusy = true;
    _clearError();
    notifyListeners();
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void _clearError() {
    error = null;
    errorStation = null;
    _scannedBikeBatteryPercent = null;
  }

  void _startClock() {
    _stopClock();
    if (!enableClock || isTrackingPaused) return;
    _rideTimer = Timer.periodic(const Duration(seconds: 1), (_) => tickRide());
    _startLocationTracking();
  }

  void _stopClock() {
    _rideTimer?.cancel();
    _rideTimer = null;
    _stopLocationTracking();
  }

  void _startLocationTracking() {
    _stopLocationTracking();
    if (!enableClock || isTrackingPaused) return;

    unawaited(_fetchInitialGpsPosition());

    try {
      const settings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      );
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: settings,
      ).listen(
        _onPositionUpdate,
        onError: (err) {
          debugPrint('GPS location stream error: $err');
          gpsAvailable = false;
          error = RentalError.gpsLost;
          notifyListeners();
        },
      );
    } catch (e) {
      debugPrint('Error starting GPS tracking: $e');
    }
  }

  Future<void> _fetchInitialGpsPosition() async {
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 4));
      _onPositionUpdate(pos);
    } catch (_) {
      try {
        final lastPos = await Geolocator.getLastKnownPosition();
        if (lastPos != null) {
          _onPositionUpdate(lastPos);
        }
      } catch (_) {}
    }
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _lastGpsPosition = null;
  }

  void _onPositionUpdate(Position position) {
    if (isTrackingPaused) return;

    final rentalStillActive = switch (stage) {
      RentalStage.riding ||
      RentalStage.selectingReturn ||
      RentalStage.returning => true,
      _ => false,
    };
    if (!rentalStillActive) {
      _stopLocationTracking();
      return;
    }

    gpsAvailable = true;
    if (error == RentalError.gpsLost) {
      _clearError();
    }

    final newLatLng = LatLng(position.latitude, position.longitude);
    riderLatLng = newLatLng;

    double? heading = position.heading;
    if (heading == 0.0 && _lastGpsPosition != null) {
      final calcBearing = Geolocator.bearingBetween(
        _lastGpsPosition!.latitude,
        _lastGpsPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      if (calcBearing != 0.0) {
        heading = calcBearing;
      }
    }
    if (heading != 0.0) {
      riderHeading = heading;
    }

    // Accumulate distance moved during active riding
    if (_lastGpsPosition != null && stage == RentalStage.riding) {
      final distanceMeters = Geolocator.distanceBetween(
        _lastGpsPosition!.latitude,
        _lastGpsPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      // Filter out noise/jitter: must move at least 2 meters and accuracy must be reliable
      if (distanceMeters >= 2.0 && position.accuracy <= 35.0) {
        metrics = metrics.copyWith(
          distanceKm: metrics.distanceKm + (distanceMeters / 1000.0),
        );
        rideRoutePoints.add(newLatLng);
      }
    } else {
      if (rideRoutePoints.isEmpty) {
        rideRoutePoints.add(newLatLng);
      }
    }
    _lastGpsPosition = position;

    // Update distance to selected station if selecting return
    if (selectedStation != null) {
      stationDistanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        selectedStation!.latitude,
        selectedStation!.longitude,
      ).round();
      isAtStation = stationDistanceMeters! <= returnGeofenceRadiusMeters;
    }

    // Keep listed station distances live while the rider moves.
    if (stations.isNotEmpty) {
      stations = [
        for (final listedStation in stations)
          (listedStation.latitude == 0 && listedStation.longitude == 0)
              ? listedStation
              : listedStation.copyWith(
                  distanceMeters: Geolocator.distanceBetween(
                    position.latitude,
                    position.longitude,
                    listedStation.latitude,
                    listedStation.longitude,
                  ).round(),
                ),
      ];
    }

    notifyListeners();
  }

  /// Pause tracking and timer when app is paused or page is not being viewed
  void pauseTracking() {
    if (isTrackingPaused) return;
    isTrackingPaused = true;
    _rideTimer?.cancel();
    _rideTimer = null;
    _positionSubscription?.pause();
  }

  /// Resume tracking and timer when app is resumed and page is visible
  void resumeTracking() {
    if (!isTrackingPaused) return;
    isTrackingPaused = false;
    final rentalStillActive = switch (stage) {
      RentalStage.riding ||
      RentalStage.selectingReturn ||
      RentalStage.returning => true,
      _ => false,
    };
    if (rentalStillActive) {
      _startClock();
      if (_positionSubscription?.isPaused ?? false) {
        _positionSubscription?.resume();
      } else if (_positionSubscription == null) {
        _startLocationTracking();
      }
    }
  }

  void _startBikeReadyTimer() {
    _stopBikeReadyTimer();
    final serverExpiresAt = _session?.rental.reservationExpiresAt;
    if (serverExpiresAt != null && !serverExpiresAt.isAfter(_now())) {
      // Already expired server-side; the next tick fires the timeout.
      _bikeReadyExpiresAt = serverExpiresAt;
    } else {
      _bikeReadyExpiresAt = serverExpiresAt ?? _now().add(bikeReadyTimeout);
    }
    if (!enableClock) return;
    _bikeReadyTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickBikeReady();
    });
  }

  void _stopBikeReadyTimer() {
    _bikeReadyTimer?.cancel();
    _bikeReadyTimer = null;
    _bikeReadyExpiresAt = null;
  }

  void _tickBikeReady() {
    if (stage != RentalStage.bikeCheck && stage != RentalStage.authorizing) {
      _stopBikeReadyTimer();
      return;
    }
    final remaining = bikeReadyRemainingSeconds ?? 0;
    if (remaining <= 0) {
      _stopBikeReadyTimer();
      unawaited(handleBikeReadyTimeout());
    } else {
      notifyListeners();
    }
  }

  Future<void> tickBikeReady({int seconds = 1}) async {
    if (stage != RentalStage.bikeCheck && stage != RentalStage.authorizing) {
      return;
    }
    final remaining = bikeReadyRemainingSeconds ?? 0;
    if (remaining <= 0) {
      _stopBikeReadyTimer();
      await handleBikeReadyTimeout();
    } else {
      notifyListeners();
    }
  }

  Future<void> handleBikeReadyTimeout() async {
    _stopBikeReadyTimer();
    if (stage == RentalStage.bikeCheck || stage == RentalStage.authorizing) {
      await cancelReservation();
      if (stage != RentalStage.scan) {
        _resetLocal();
      }
      _timeoutController.add(null);
    }
  }

  void handleAppExit() {
    if (stage == RentalStage.bikeCheck ||
        stage == RentalStage.authorizing ||
        stage == RentalStage.unlocking) {
      final id = rentalId;
      _stopBikeReadyTimer();
      _resetLocal();
      if (id != null) {
        unawaited(repository.cancelSession(id).catchError((_) {}));
      }
    }
  }

  void _resetLocal() {
    _stopClock();
    _stopLocationTracking();
    _stopBikeReadyTimer();
    _stopRealtimeEvents();
    _session = null;
    _completedSession = null;
    _bikeReports = const [];
    _isLoadingBikeReports = false;
    stage = RentalStage.scan;
    metrics = const RideMetrics(elapsedSeconds: 0, distanceKm: 0);
    authorization = const PaymentAuthorization(
      amount: defaultHoldAmount,
      status: PaymentStatus.ready,
    );
    bike = null;
    startStation = null;
    selectedPaymentMethod = null;
    selectedStation = null;
    receipt = null;
    _clearError();
    isBusy = false;
    gpsAvailable = true;
    isAtStation = false;
    stationQrToken = null;
    stationDistanceMeters = null;
    _arrivalPosition = null;
    _paypalOrder = null;
    _paypalOrderLocale = null;
    _paypalAuthorizationId = null;
    _scannedBikeCode = null;
    _scannedBikeBatteryPercent = null;
    _hasAcknowledgedLowBatteryWarning = false;
    riderLatLng = null;
    riderHeading = null;
    rideRoutePoints.clear();
    _lastGpsPosition = null;
    isTrackingPaused = false;
    _depositDurationOverride = null;
    _suspiciousDistanceMetersOverride = null;
    _isSuspiciousDistanceOverride = null;
    _distanceFromStartStationOverride = null;
    notifyListeners();
  }

  bool _disposed = false;

  @override
  void notifyListeners() {
    if (!_disposed) {
      super.notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _stopClock();
    _stopLocationTracking();
    _stopBikeReadyTimer();
    _stopRealtimeEvents();
    _timeoutController.close();
    _forceEndController.close();
    if (_ownsPayPalGateway) _paypalGateway.close();
    super.dispose();
  }
}
