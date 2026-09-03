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

enum RentalIssueType { brakes, tyres, lights, lock, other }

enum RentalError {
  authenticationFailed,
  connectionFailed,
  accountSuspended,
  activeRentalExists,
  invalidTransition,
  invalidQr,
  bikeReserved,
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

class RentalIssueNote {
  const RentalIssueNote({
    required this.type,
    required this.note,
    required this.notedAt,
  });

  final RentalIssueType type;
  final String note;
  final DateTime notedAt;
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
    required this.distanceMeters,
    required this.availableDocks,
    this.qrToken = '',
    this.latitude = 0,
    this.longitude = 0,
  });

  final int backendId;
  final String id;
  final String name;
  final int distanceMeters;
  final int availableDocks;
  final String qrToken;
  final double latitude;
  final double longitude;
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
