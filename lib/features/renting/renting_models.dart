enum RentalStage {
  scan,
  bikeCheck,
  authorizing,
  unlocking,
  riding,
  selectingReturn,
  returning,
  charging,
  receipt,
}

enum PaymentStatus { ready, authorized, paid, pending }

enum RentalError {
  authenticationFailed,
  connectionFailed,
  accountSuspended,
  activeRentalExists,
  invalidTransition,
  invalidQr,
  bikeReserved,
  bikeMaintenance,
  bikeUnavailable,
  bikeLowBattery,
  stationMaintenance,
  stationTerminated,
  holdDeclined,
  paymentConfiguration,
  paymentNetwork,
  paymentCancelled,
  paymentAuthorizationFailed,
  paymentCaptureFailed,
  lockFailed,
  gpsLost,
  locationPermissionDenied,
  stationFull,
  chooseStation,
  outsideReturnZone,
  stationQrMismatch,
  dockNotDetected,
  maxExtensionsReached,
}

class RentalBike {
  const RentalBike({required this.id, required this.batteryPercent});

  final String id;
  final int batteryPercent;
}

class RideMetrics {
  const RideMetrics({required this.elapsedSeconds, required this.distanceKm});

  final int elapsedSeconds;
  final double distanceKm;

  RideMetrics copyWith({int? elapsedSeconds, double? distanceKm}) {
    return RideMetrics(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      distanceKm: distanceKm ?? this.distanceKm,
    );
  }
}

class ReturnStation {
  const ReturnStation({
    required this.backendId,
    required this.id,
    required this.name,
    this.distanceMeters,
    required this.availableDocks,
    this.availableBikes = 0,
    this.capacity = 0,
    this.qrToken = '',
    this.latitude = 0,
    this.longitude = 0,
    this.status = 'Normal',
  });

  final int backendId;
  final String id;
  final String name;
  final int? distanceMeters;
  final int availableDocks;
  final int availableBikes;
  final int capacity;
  final String qrToken;
  final double latitude;
  final double longitude;
  final String status;

  bool get isUnderMaintenance =>
      status.trim().toLowerCase() == 'under maintenance';
  bool get isTerminated => status.trim().toLowerCase() == 'terminated';
  bool get isNormal => !isUnderMaintenance && !isTerminated;
  bool get canAcceptReturn =>
      !isUnderMaintenance && !isTerminated && availableDocks > 0;

  ReturnStation copyWith({int? distanceMeters}) {
    return ReturnStation(
      backendId: backendId,
      id: id,
      name: name,
      distanceMeters: distanceMeters,
      availableDocks: availableDocks,
      availableBikes: availableBikes,
      capacity: capacity,
      qrToken: qrToken,
      latitude: latitude,
      longitude: longitude,
      status: status,
    );
  }
}

class RentalPaymentMethod {
  const RentalPaymentMethod({
    required this.id,
    required this.brand,
    required this.lastFour,
  });

  final String id;
  final String brand;
  final String lastFour;
}

class PaymentAuthorization {
  const PaymentAuthorization({required this.amount, required this.status});

  final double amount;
  final PaymentStatus status;
}

class RentalReceipt {
  const RentalReceipt({
    required this.rideId,
    required this.finalFare,
    required this.releasedHold,
    required this.elapsedSeconds,
    required this.distanceKm,
    required this.returnStation,
    required this.paymentStatus,
  });

  final String rideId;
  final double finalFare;
  final double releasedHold;
  final int elapsedSeconds;
  final double distanceKm;
  final ReturnStation returnStation;
  final PaymentStatus paymentStatus;

  RentalReceipt copyWith({PaymentStatus? paymentStatus}) {
    return RentalReceipt(
      rideId: rideId,
      finalFare: finalFare,
      releasedHold: releasedHold,
      elapsedSeconds: elapsedSeconds,
      distanceKm: distanceKm,
      returnStation: returnStation,
      paymentStatus: paymentStatus ?? this.paymentStatus,
    );
  }
}

enum RideWarningSeverity {
  warning,
  critical,
}

enum RideWarningType {
  depositExceeded,
  doubleDepositLegalAction,
  suspiciousActivity,
  suspiciousLegalAction,
}

class ActiveRideWarning {
  const ActiveRideWarning({
    required this.type,
    required this.severity,
    required this.title,
    required this.message,
  });

  final RideWarningType type;
  final RideWarningSeverity severity;
  final String title;
  final String message;

  bool get isCritical => severity == RideWarningSeverity.critical;
  bool get isWarning => severity == RideWarningSeverity.warning;
}

