import 'dart:async';
import 'dart:math' as math;

import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:flutter/foundation.dart';

class RentingController extends ChangeNotifier {
  RentingController();

  static const unlockFee = 0.50;
  static const perMinuteRate = 0.10;
  static const holdAmount = 20.00;

  // TODO: Load bike details from the bike service after QR validation.
  final bike = const RentalBike(id: 'BIKE-C042', batteryPercent: 86);

  // TODO: Load nearby return stations and live dock counts from the station
  // service using the rider's current location.
  final stations = const [
    ReturnStation(id: 'central', distanceMeters: 120, availableDocks: 8),
    ReturnStation(id: 'riverside', distanceMeters: 260, availableDocks: 0),
    ReturnStation(id: 'market', distanceMeters: 430, availableDocks: 5),
    ReturnStation(id: 'university', distanceMeters: 610, availableDocks: 3),
  ];

  // TODO: Load saved payment methods from the authenticated user's wallet.
  final paymentMethods = const [
    RentalPaymentMethod(id: 'visa-4242', brand: 'Visa', lastFour: '4242'),
    RentalPaymentMethod(
      id: 'mastercard-4444',
      brand: 'Mastercard',
      lastFour: '4444',
    ),
  ];

  RentalStage stage = RentalStage.scan;
  RideMetrics metrics = const RideMetrics(elapsedSeconds: 0, distanceKm: 0);
  PaymentAuthorization authorization = const PaymentAuthorization(
    amount: holdAmount,
    status: PaymentStatus.ready,
  );
  RentalPaymentMethod? selectedPaymentMethod;
  ReturnStation? selectedStation;
  RentalReceipt? receipt;
  RentalError? error;
  ReturnStation? errorStation;
  bool isBusy = false;
  bool gpsAvailable = true;
  bool isAtStation = false;
  Timer? _rideTimer;

  bool get isFlowLocked => switch (stage) {
    RentalStage.unlocking ||
    RentalStage.riding ||
    RentalStage.selectingReturn ||
    RentalStage.returning ||
    RentalStage.charging => true,
    _ => false,
  };

  bool get canGoBack => switch (stage) {
    RentalStage.bikeCheck ||
    RentalStage.authorizing ||
    RentalStage.unlocking ||
    RentalStage.selectingReturn => true,
    _ => false,
  };

  int get chargedMinutes => math.max(1, (metrics.elapsedSeconds / 60).ceil());

  double get estimatedFare => unlockFee + (chargedMinutes * perMinuteRate);

  double get releasedHold => math.max(0, holdAmount - estimatedFare);

  void scanBike({bool invalid = false, bool unavailable = false}) {
    _clearError();
    if (invalid) {
      error = RentalError.invalidQr;
      notifyListeners();
      return;
    }
    if (unavailable) {
      error = RentalError.bikeReserved;
      notifyListeners();
      return;
    }

    selectedPaymentMethod ??= paymentMethods.first;
    stage = RentalStage.bikeCheck;
    notifyListeners();
  }

  void selectPaymentMethod(RentalPaymentMethod method) {
    selectedPaymentMethod = method;
    notifyListeners();
  }

  void reviewAuthorization() {
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

  bool goBack() {
    if (isBusy) return true;

    switch (stage) {
      case RentalStage.bikeCheck:
        reset();
        return true;
      case RentalStage.authorizing:
        backToBikeCheck();
        return true;
      case RentalStage.unlocking:
        reset();
        return true;
      case RentalStage.selectingReturn:
        resumeRide();
        return true;
      case RentalStage.scan:
      case RentalStage.riding:
      case RentalStage.returning:
      case RentalStage.charging:
      case RentalStage.receipt:
        return false;
    }
  }

  Future<void> authorizeHold({bool fail = false}) async {
    if (isBusy) return;
    _beginBusy();
    await _operationDelay();
    if (fail) {
      isBusy = false;
      error = RentalError.holdDeclined;
      notifyListeners();
      return;
    }

    authorization = const PaymentAuthorization(
      amount: holdAmount,
      status: PaymentStatus.authorized,
    );
    isBusy = false;
    _clearError();
    stage = RentalStage.unlocking;
    notifyListeners();
  }

  Future<void> unlockBike({bool fail = false}) async {
    if (isBusy) return;
    _beginBusy();
    await _operationDelay();
    if (fail) {
      isBusy = false;
      error = RentalError.lockFailed;
      notifyListeners();
      return;
    }

    isBusy = false;
    _clearError();
    stage = RentalStage.riding;
    _startClock();
    notifyListeners();
  }

  void tickRide({int seconds = 1, double distanceKm = 0.004}) {
    final rentalStillActive = switch (stage) {
      RentalStage.riding ||
      RentalStage.selectingReturn ||
      RentalStage.returning => true,
      _ => false,
    };
    if (!rentalStillActive || !gpsAvailable) return;
    metrics = metrics.copyWith(
      elapsedSeconds: metrics.elapsedSeconds + seconds,
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

  void findReturnStation() {
    _clearError();
    stage = RentalStage.selectingReturn;
    notifyListeners();
  }

  void resumeRide() {
    _clearError();
    stage = RentalStage.riding;
    notifyListeners();
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
    // TODO: Replace this manual confirmation with station geofence data.
    if (selectedStation == null) {
      error = RentalError.chooseStation;
    } else {
      isAtStation = true;
      _clearError();
    }
    notifyListeners();
  }

  void beginReturn() {
    if (selectedStation == null) {
      error = RentalError.chooseStation;
      notifyListeners();
      return;
    }
    if (!isAtStation) {
      error = RentalError.outsideReturnZone;
      notifyListeners();
      return;
    }

    _clearError();
    stage = RentalStage.returning;
    notifyListeners();
  }

  Future<void> confirmDock({bool fail = false}) async {
    if (isBusy) return;
    _beginBusy();
    await _operationDelay();
    if (fail) {
      isBusy = false;
      error = RentalError.dockNotDetected;
      notifyListeners();
      return;
    }

    _stopClock();
    isBusy = false;
    _clearError();
    stage = RentalStage.charging;
    notifyListeners();
  }

  Future<void> capturePayment({bool fail = false}) async {
    if (isBusy || selectedStation == null) return;
    _beginBusy();
    await _operationDelay();
    isBusy = false;
    _clearError();
    // TODO: Use the ride ID and payment result returned by the renting service.
    receipt = RentalReceipt(
      rideId: 'RIDE-2407-C042',
      finalFare: estimatedFare,
      releasedHold: releasedHold,
      elapsedSeconds: metrics.elapsedSeconds,
      distanceKm: metrics.distanceKm,
      returnStation: selectedStation!,
      paymentStatus: fail ? PaymentStatus.pending : PaymentStatus.paid,
    );
    stage = RentalStage.receipt;
    notifyListeners();
  }

  Future<void> retryPayment() async {
    if (isBusy || receipt?.paymentStatus != PaymentStatus.pending) return;
    _beginBusy();
    await _operationDelay();
    isBusy = false;
    receipt = receipt?.copyWith(paymentStatus: PaymentStatus.paid);
    notifyListeners();
  }

  void reset() {
    _stopClock();
    stage = RentalStage.scan;
    metrics = const RideMetrics(elapsedSeconds: 0, distanceKm: 0);
    authorization = const PaymentAuthorization(
      amount: holdAmount,
      status: PaymentStatus.ready,
    );
    selectedPaymentMethod = null;
    selectedStation = null;
    receipt = null;
    _clearError();
    isBusy = false;
    gpsAvailable = true;
    isAtStation = false;
    notifyListeners();
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

  Future<void> _operationDelay() {
    return Future<void>.delayed(const Duration(milliseconds: 450));
  }

  void _startClock() {
    _stopClock();
    _rideTimer = Timer.periodic(const Duration(seconds: 1), (_) => tickRide());
  }

  void _stopClock() {
    _rideTimer?.cancel();
    _rideTimer = null;
  }

  @override
  void dispose() {
    _stopClock();
    super.dispose();
  }
}
