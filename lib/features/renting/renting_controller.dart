import 'dart:async';
import 'dart:math' as math;

import 'package:bike_renting_app/data/database/database_exception.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/data/models/rental_session_snapshot.dart';
import 'package:bike_renting_app/data/repositories/payment_method_repository.dart';
import 'package:bike_renting_app/data/repositories/rental_repository.dart';
import 'package:bike_renting_app/features/renting/rental_payment_simulator.dart';
import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RentingController extends ChangeNotifier {
  RentingController({
    required this.repository,
    this.paymentMethodRepository,
    this.paymentSimulator = const LocalRentalPaymentSimulator(),
    DateTime Function()? now,
    this.enableClock = true,
    this.debugSource,
  }) : _now = now ?? DateTime.now;

  static const demoBikeQrToken = '00000000-0000-4000-8000-000000000042';
  static const demoBikeCode = 'BIKE-C042';
  static const defaultUnlockFee = 0.50;
  static const defaultPerMinuteRate = 0.10;
  static const _initializationRetryDelay = Duration(milliseconds: 250);

  static const paymentMethods = [
    RentalPaymentMethod(
      id: 'test-payment',
      brand: 'BikeRent Test',
      lastFour: '4242',
    ),
  ];

  final RentalSessionRepository repository;
  final PaymentMethodRepository? paymentMethodRepository;
  final RentalPaymentSimulator paymentSimulator;
  final DebugRentBikeSource? debugSource;
  final DateTime Function() _now;
  final bool enableClock;

  List<RentalPaymentMethod> availablePaymentMethods = paymentMethods;

  Future<void>? _initialization;
  RentalSessionSnapshot? _session;
  RentalSessionSnapshot? _completedSession;
  Timer? _rideTimer;
  final List<RentalIssueNote> _localIssueNotes = [];

  RentalStage stage = RentalStage.scan;
  RideMetrics metrics = const RideMetrics(elapsedSeconds: 0, distanceKm: 0);
  PaymentAuthorization authorization = const PaymentAuthorization(
    amount: 0,
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

  int? get rentalId => _session?.rental.id;

  List<RentalIssueNote> get localIssueNotes =>
      List.unmodifiable(_localIssueNotes);

  String get bikeCode => bike?.id ?? demoBikeCode;

  double get unlockFee =>
      _completedSession?.rental.unlockFee ?? _session?.rental.unlockFee ?? 0;

  double get perMinuteRate =>
      _completedSession?.rental.perMinuteRate ??
      _session?.rental.perMinuteRate ??
      0;

  double get holdAmount =>
      _completedSession?.rental.holdAmount ?? _session?.rental.holdAmount ?? 0;

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

  Future<void> initialize() {
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    try {
      _clearError();
      final results = await _loadInitializationData();
      stations = (results[0] as List<StationAvailabilityRecord>)
          .map(_stationFromDatabase)
          .toList(growable: false);
      final active = results[1] as RentalSessionSnapshot?;
      final paymentRecords = results[2] as List<PaymentMethodRecord>;
      if (paymentRecords.isNotEmpty) {
        availablePaymentMethods = paymentRecords
            .map(
              (p) => RentalPaymentMethod(
                id: p.id.toString(),
                brand: p.brand,
                lastFour: p.lastFour,
              ),
            )
            .toList(growable: false);
      } else {
        availablePaymentMethods = paymentMethods;
      }
      if (active != null) _applySnapshot(active);
    } catch (caught) {
      error = _mapError(caught);
    } finally {
      isInitialized = true;
      notifyListeners();
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

  Future<void> scanBike([String? qrToken]) async {
    if (isBusy) return;
    await initialize();
    if (error != null && _session == null) return;

    final token = (qrToken != null && qrToken.trim().isNotEmpty)
        ? qrToken.trim()
        : demoBikeQrToken;

    // TODO(qr): Replace this fixed fixture token with Android camera scanning
    // and validated bikerenting:// deep links.
    await _run(() async {
      final snapshot = await repository.reserveSession(token);
      _applySnapshot(snapshot);
    });
  }

  /// DEBUG ONLY: every bike in the system, any status, for the camera-less
  /// debug bike picker on the scan stage.
  Future<List<BikeDatabaseRecord>> listDebugBikes() async {
    final source = debugSource;
    if (source == null) return const [];
    return source.listAllBikes();
  }

  void selectPaymentMethod(RentalPaymentMethod method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void reviewAuthorization() {
    if (_session?.rental.status != RentalDatabaseStatus.reserved) return;
    _clearError();
    stage = RentalStage.authorizing;
    notifyListeners();
  }

  void backToBikeCheck() {
    if (isBusy) return;
    _clearError();
    stage = RentalStage.bikeCheck;
    notifyListeners();
  }

  Future<void> authorizePayment() async {
    if (isBusy || _session?.rental.status != RentalDatabaseStatus.reserved) {
      return;
    }
    _beginBusy();
    try {
      await paymentSimulator.authorize(holdAmount);
      authorization = PaymentAuthorization(
        amount: holdAmount,
        status: PaymentStatus.authorized,
      );
      _clearError();
      stage = RentalStage.unlocking;
    } on RentalPaymentSimulationException {
      error = RentalError.holdDeclined;
    } finally {
      isBusy = false;
      notifyListeners();
    }
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
      _applySnapshot(await repository.startSession(id));
      _clearError();
    } catch (caught) {
      error = _mapError(caught);
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
    if (!rentalStillActive || !gpsAvailable) return;

    // TODO(gps): Replace simulated distance with validated Android location
    // samples and checkpoint progress for crash-safe distance recovery.
    metrics = metrics.copyWith(
      elapsedSeconds: math.max(
        metrics.elapsedSeconds + seconds,
        _elapsedFromServerStart(),
      ),
      distanceKm: metrics.distanceKm + distanceKm,
    );
    notifyListeners();
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

  void noteRideIssue(RentalIssueType type, String note) {
    if (!isRideActive) return;
    _localIssueNotes.add(
      RentalIssueNote(type: type, note: note.trim(), notedAt: _now()),
    );
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
      _clearError();
      stage = RentalStage.riding;
      notifyListeners();
      return;
    }

    await _run(() async {
      final localDistance = metrics.distanceKm;
      selectedStation = null;
      isAtStation = false;
      _applySnapshot(await repository.resumeSession(id));
      metrics = metrics.copyWith(
        distanceKm: math.max(metrics.distanceKm, localDistance),
      );
    });
  }

  void selectStation(ReturnStation station) {
    if (station.availableDocks == 0) {
      error = RentalError.stationFull;
      errorStation = station;
      notifyListeners();
      return;
    }
    selectedStation = station;
    isAtStation = false;
    _clearError();
    notifyListeners();
  }

  void confirmArrival() {
    // TODO(geofence): Replace manual arrival with Android location/geofence
    // validation against the selected station coordinates.
    if (selectedStation == null) {
      error = RentalError.chooseStation;
    } else {
      isAtStation = true;
      _clearError();
    }
    notifyListeners();
  }

  Future<void> beginReturn() async {
    final id = rentalId;
    final station = selectedStation;
    if (station == null) {
      error = RentalError.chooseStation;
      notifyListeners();
      return;
    }
    if (!isAtStation) {
      error = RentalError.outsideReturnZone;
      notifyListeners();
      return;
    }
    if (isBusy || id == null) return;

    await _run(() async {
      final localDistance = metrics.distanceKm;
      _applySnapshot(
        await repository.requestSessionReturn(
          rentalId: id,
          stationId: station.backendId,
        ),
      );
      metrics = metrics.copyWith(
        distanceKm: math.max(metrics.distanceKm, localDistance),
      );
    });
  }

  Future<void> confirmDock({bool fail = false}) async {
    final id = rentalId;
    if (isBusy || id == null) return;
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
    } catch (caught) {
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
    if (id == null ||
        _session?.rental.status != RentalDatabaseStatus.reserved) {
      _resetLocal();
      return;
    }

    final succeeded = await _run(() => repository.cancelSession(id));
    if (succeeded) _resetLocal();
  }

  Future<void> reset() async {
    if (_session?.rental.status == RentalDatabaseStatus.reserved) {
      await cancelReservation();
      return;
    }
    _resetLocal();
  }

  RentalReceipt _buildReceipt(PaymentStatus status) {
    final completed = _completedSession!;
    return RentalReceipt(
      rideId: completed.rental.publicId,
      finalFare: completed.rental.finalFare!,
      releasedHold: releasedHold,
      elapsedSeconds: completed.rental.durationSeconds,
      distanceKm: completed.rental.distanceKm,
      returnStation: selectedStation!,
      paymentStatus: status,
    );
  }

  void _applySnapshot(RentalSessionSnapshot snapshot) {
    _session = snapshot;
    bike = RentalBike(
      id: snapshot.bike.code,
      batteryPercent: snapshot.bike.batteryPercent,
    );
    startStation = _stationFromDatabase(snapshot.startStation);
    selectedPaymentMethod ??=
        availablePaymentMethods.firstOrNull ?? paymentMethods.first;

    switch (snapshot.rental.status) {
      case RentalDatabaseStatus.reserved:
        _stopClock();
        authorization = PaymentAuthorization(
          amount: snapshot.rental.holdAmount,
          status: PaymentStatus.ready,
        );
        metrics = const RideMetrics(elapsedSeconds: 0, distanceKm: 0);
        selectedStation = null;
        isAtStation = false;
        stage = RentalStage.bikeCheck;
        break;
      case RentalDatabaseStatus.active:
        metrics = RideMetrics(
          elapsedSeconds: _elapsedFromServerStart(),
          distanceKm: snapshot.rental.distanceKm,
        );
        selectedStation = null;
        isAtStation = false;
        stage = RentalStage.riding;
        _startClock();
        break;
      case RentalDatabaseStatus.returning:
        metrics = RideMetrics(
          elapsedSeconds: _elapsedFromServerStart(),
          distanceKm: snapshot.rental.distanceKm,
        );
        selectedStation = _stationFromSnapshot(snapshot.endStation);
        isAtStation = true;
        stage = RentalStage.returning;
        _startClock();
        break;
      case RentalDatabaseStatus.authorized:
        authorization = PaymentAuthorization(
          amount: snapshot.rental.holdAmount,
          status: PaymentStatus.authorized,
        );
        stage = RentalStage.unlocking;
        break;
      case RentalDatabaseStatus.completed:
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
      case RentalDatabaseStatus.pendingAuthorization:
      case RentalDatabaseStatus.paymentPending:
      case RentalDatabaseStatus.paymentFailed:
        error = RentalError.invalidTransition;
        break;
      case RentalDatabaseStatus.cancelled:
        _resetLocal();
        break;
    }
  }

  ReturnStation _stationFromDatabase(StationAvailabilityRecord station) {
    return ReturnStation(
      backendId: station.id,
      id: station.code,
      name: station.name,
      // TODO(gps): Calculate rider-relative distance from Android location.
      distanceMeters: switch (station.code) {
        'central' => 120,
        'riverside' => 260,
        'market' => 430,
        'university' => 610,
        _ => 0,
      },
      availableDocks: station.availableDocks,
    );
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
      DatabaseErrorCode.activeRentalExists => RentalError.activeRentalExists,
      DatabaseErrorCode.bikeUnavailable => RentalError.bikeReserved,
      DatabaseErrorCode.notFound => RentalError.invalidQr,
      DatabaseErrorCode.stationFull => RentalError.stationFull,
      DatabaseErrorCode.invalidRentalTransition =>
        RentalError.invalidTransition,
      _ => RentalError.connectionFailed,
    };
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

  void _clearError() {
    error = null;
    errorStation = null;
  }

  void _startClock() {
    _stopClock();
    if (!enableClock) return;
    _rideTimer = Timer.periodic(const Duration(seconds: 1), (_) => tickRide());
  }

  void _stopClock() {
    _rideTimer?.cancel();
    _rideTimer = null;
  }

  void _resetLocal() {
    _stopClock();
    _session = null;
    _completedSession = null;
    stage = RentalStage.scan;
    metrics = const RideMetrics(elapsedSeconds: 0, distanceKm: 0);
    authorization = const PaymentAuthorization(
      amount: 0,
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
    notifyListeners();
  }

  @override
  void dispose() {
    _stopClock();
    super.dispose();
  }
}
