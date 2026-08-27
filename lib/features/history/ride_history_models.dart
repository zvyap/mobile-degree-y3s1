import 'package:bike_renting_app/data/models/database_models.dart';

class RidePaymentBreakdown {
  const RidePaymentBreakdown({
    required this.deposit,
    required this.unlockFee,
    required this.perMinuteRate,
    required this.startedMinutes,
    required this.finalFare,
    required this.maskedPaymentMethod,
  });

  final double deposit;
  final double unlockFee;
  final double perMinuteRate;
  final int startedMinutes;
  final double finalFare;
  final String maskedPaymentMethod;

  double get minuteCharge => perMinuteRate * startedMinutes;
  double get refundedDeposit => deposit - finalFare;
}

class RideHistoryEntry {
  const RideHistoryEntry({
    required this.rideId,
    required this.bikeId,
    required this.startedAt,
    required this.endedAt,
    required this.startStation,
    required this.endStation,
    required this.durationSeconds,
    required this.distanceKm,
    required this.payment,
  });

  final String rideId;
  final String bikeId;
  final DateTime startedAt;
  final DateTime endedAt;
  final String startStation;
  final String endStation;
  final int durationSeconds;
  final double distanceKm;
  final RidePaymentBreakdown payment;

  factory RideHistoryEntry.fromDatabase(RentalHistoryDatabaseRecord record) {
    final rental = record.rental;
    final paymentMethod = record.paymentBrand == null
        ? 'Payment method unavailable'
        : '${record.paymentBrand} •••• ${record.paymentLastFour ?? ''}'.trim();

    return RideHistoryEntry(
      rideId: rental.publicId,
      bikeId: record.bikeCode,
      startedAt: rental.startedAt!,
      endedAt: rental.endedAt!,
      startStation: record.startStationName,
      endStation: record.endStationName,
      durationSeconds: rental.durationSeconds,
      distanceKm: rental.distanceKm,
      payment: RidePaymentBreakdown(
        deposit: rental.holdAmount,
        unlockFee: rental.unlockFee,
        perMinuteRate: rental.perMinuteRate,
        startedMinutes: rental.chargedMinutes,
        finalFare: rental.finalFare!,
        maskedPaymentMethod: paymentMethod,
      ),
    );
  }
}

final List<RideHistoryEntry> demoRideHistory = List.unmodifiable([
  RideHistoryEntry(
    rideId: 'RIDE-1108-A104',
    bikeId: 'BK-042',
    startedAt: DateTime(2026, 8, 11, 8, 10),
    endedAt: DateTime(2026, 8, 11, 8, 28, 32),
    startStation: 'Central Station',
    endStation: 'University Gate',
    durationSeconds: 1112,
    distanceKm: 4.6,
    payment: const RidePaymentBreakdown(
      deposit: 20,
      unlockFee: 1.5,
      perMinuteRate: 0.2,
      startedMinutes: 19,
      finalFare: 5.3,
      maskedPaymentMethod: 'Visa •••• 4242',
    ),
  ),
  RideHistoryEntry(
    rideId: 'RIDE-0908-B219',
    bikeId: 'BK-118',
    startedAt: DateTime(2026, 8, 9, 17, 42),
    endedAt: DateTime(2026, 8, 9, 17, 54, 14),
    startStation: 'Riverside Park',
    endStation: 'Market Square',
    durationSeconds: 734,
    distanceKm: 3.1,
    payment: const RidePaymentBreakdown(
      deposit: 20,
      unlockFee: 1.5,
      perMinuteRate: 0.2,
      startedMinutes: 13,
      finalFare: 4.1,
      maskedPaymentMethod: 'Visa •••• 4242',
    ),
  ),
  RideHistoryEntry(
    rideId: 'RIDE-0408-C087',
    bikeId: 'BK-076',
    startedAt: DateTime(2026, 8, 4, 7, 55),
    endedAt: DateTime(2026, 8, 4, 8, 22, 5),
    startStation: 'Library Station',
    endStation: 'Central Station',
    durationSeconds: 1625,
    distanceKm: 6.8,
    payment: const RidePaymentBreakdown(
      deposit: 20,
      unlockFee: 1.5,
      perMinuteRate: 0.2,
      startedMinutes: 28,
      finalFare: 7.1,
      maskedPaymentMethod: 'Visa •••• 4242',
    ),
  ),
  RideHistoryEntry(
    rideId: 'RIDE-2807-D331',
    bikeId: 'BK-205',
    startedAt: DateTime(2026, 7, 28, 18, 6),
    endedAt: DateTime(2026, 7, 28, 18, 15, 40),
    startStation: 'Main Gate',
    endStation: 'Riverside Park',
    durationSeconds: 580,
    distanceKm: 2.2,
    payment: const RidePaymentBreakdown(
      deposit: 20,
      unlockFee: 1.5,
      perMinuteRate: 0.2,
      startedMinutes: 10,
      finalFare: 3.5,
      maskedPaymentMethod: 'Visa •••• 4242',
    ),
  ),
]);
