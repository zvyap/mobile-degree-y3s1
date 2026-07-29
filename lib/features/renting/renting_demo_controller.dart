import 'dart:async';
import 'dart:math' as math;

import 'package:bike_renting_app/features/renting/renting_models.dart';
import 'package:flutter/foundation.dart';

class RentingDemoController extends ChangeNotifier {
  RentingDemoController({
    this.enableClock = true,
    this.demoDelay = const Duration(milliseconds: 450),
  });

  static const unlockFee = 0.50;
  static const perMinuteRate = 0.10;
  static const holdAmount = 20.00;

  final bool enableClock;
  final Duration demoDelay;

  final bike = const RentalBike(
    id: 'BIKE-C042',
    batteryPercent: 86,
    location: 'Central Station',
  );

  final stations = const [
    ReturnStation(
      id: 'central',
      name: 'Central Station',
      distanceMeters: 120,
      availableDocks: 8,
    ),
    ReturnStation(
      id: 'riverside',
      name: 'Riverside Park',
      distanceMeters: 260,
      availableDocks: 0,
    ),
    ReturnStation(
      id: 'market',
      name: 'Market Square',
      distanceMeters: 430,
      availableDocks: 5,
    ),
    ReturnStation(
      id: 'university',
      name: 'University Gate',
      distanceMeters: 610,
      availableDocks: 3,
    ),
  ];

  final paymentMethods = const [
    RentalPaymentMethod(
      id: 'visa-4242',
      brand: 'Visa',
      lastFour: '4242',
      label: 'Personal card',
    ),
    RentalPaymentMethod(
      id: 'mastercard-4444',
      brand: 'Mastercard',
      lastFour: '4444',
      label: 'Travel card',
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
  String? errorMessage;
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

  String get formattedElapsed {
    final minutes = metrics.elapsedSeconds ~/ 60;
    final seconds = metrics.elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void scanBike({bool invalid = false, bool unavailable = false}) {
    errorMessage = null;
    if (invalid) {
      errorMessage =
          'This QR code is not a BikeRent bike. Scan the code on the bike frame.';
      notifyListeners();
      return;
    }
    if (unavailable) {
      errorMessage =
          'Bike BIKE-C042 is already reserved. Choose another bike and scan again.';
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
    errorMessage = null;
    stage = RentalStage.authorizing;
    notifyListeners();
  }

  void backToBikeCheck() {
    if (isBusy) return;
    errorMessage = null;
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
    await _demoDelay();
    if (fail) {
      isBusy = false;
      errorMessage =
          'The RM20.00 hold was declined. Try another card or retry.';
      notifyListeners();
      return;
    }

    authorization = const PaymentAuthorization(
      amount: holdAmount,
      status: PaymentStatus.authorized,
    );
    isBusy = false;
    errorMessage = null;
    stage = RentalStage.unlocking;
    notifyListeners();
  }

  Future<void> unlockBike({bool fail = false}) async {
    if (isBusy) return;
    _beginBusy();
    await _demoDelay();
    if (fail) {
      isBusy = false;
      errorMessage =
          'The lock did not respond. Stand near the bike and try again.';
      notifyListeners();
      return;
    }

    isBusy = false;
    errorMessage = null;
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
    errorMessage = value
        ? null
        : 'GPS signal lost. Move to an open area and check location access.';
    notifyListeners();
  }

  void findReturnStation() {
    errorMessage = null;
    stage = RentalStage.selectingReturn;
    notifyListeners();
  }

  void resumeRide() {
    errorMessage = null;
    stage = RentalStage.riding;
    notifyListeners();
  }

  void selectStation(ReturnStation station) {
    if (station.availableDocks == 0) {
      errorMessage =
          '${station.name} has no free docks. Choose another station.';
      notifyListeners();
      return;
    }
    selectedStation = station;
    isAtStation = false;
    errorMessage = null;
    notifyListeners();
  }

  void simulateArrival() {
    if (selectedStation == null) {
      errorMessage = 'Choose a return station first.';
    } else {
      isAtStation = true;
      errorMessage = null;
    }
    notifyListeners();
  }

  void beginReturn() {
    if (selectedStation == null) {
      errorMessage = 'Choose a return station first.';
      notifyListeners();
      return;
    }
    if (!isAtStation) {
      errorMessage =
          'Move within 50 m of the selected station before returning the bike.';
      notifyListeners();
      return;
    }

    errorMessage = null;
    stage = RentalStage.returning;
    notifyListeners();
  }

  Future<void> confirmDock({bool fail = false}) async {
    if (isBusy) return;
    _beginBusy();
    await _demoDelay();
    if (fail) {
      isBusy = false;
      errorMessage =
          'Dock not detected. Push the bike firmly into the dock and retry.';
      notifyListeners();
      return;
    }

    _stopClock();
    isBusy = false;
    errorMessage = null;
    stage = RentalStage.charging;
    notifyListeners();
  }

  Future<void> capturePayment({bool fail = false}) async {
    if (isBusy || selectedStation == null) return;
    _beginBusy();
    await _demoDelay();
    isBusy = false;
    errorMessage = null;
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
    await _demoDelay();
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
    errorMessage = null;
    isBusy = false;
    gpsAvailable = true;
    isAtStation = false;
    notifyListeners();
  }

  void _beginBusy() {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> _demoDelay() {
    return Future<void>.delayed(demoDelay);
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

  @override
  void dispose() {
    _stopClock();
    super.dispose();
  }
}
