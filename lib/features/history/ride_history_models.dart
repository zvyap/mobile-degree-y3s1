import 'package:bike_renting_app/l10n/app_localizations.dart';

enum RideStation {
  centralStation,
  universityGate,
  riversidePark,
  marketSquare,
  libraryStation,
  mainGate;

  String label(AppLocalizations l10n) => switch (this) {
    centralStation => l10n.centralStation,
    universityGate => l10n.universityGate,
    riversidePark => l10n.riversidePark,
    marketSquare => l10n.marketSquare,
    libraryStation => l10n.libraryStation,
    mainGate => l10n.mainGate,
  };
}

class RidePaymentBreakdown {
  const RidePaymentBreakdown({
    required this.deposit,
    required this.unlockFee,
    required this.perMinuteRate,
    required this.startedMinutes,
    required this.maskedPaymentMethod,
  });

  final double deposit;
  final double unlockFee;
  final double perMinuteRate;
  final int startedMinutes;
  final String maskedPaymentMethod;

  double get minuteCharge => perMinuteRate * startedMinutes;
  double get finalFare => unlockFee + minuteCharge;
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
    required this.distanceKm,
    required this.payment,
  });

  final String rideId;
  final String bikeId;
  final DateTime startedAt;
  final DateTime endedAt;
  final RideStation startStation;
  final RideStation endStation;
  final double distanceKm;
  final RidePaymentBreakdown payment;

  int get durationSeconds => endedAt.difference(startedAt).inSeconds;
}

final List<RideHistoryEntry> demoRideHistory = List.unmodifiable([
  RideHistoryEntry(
    rideId: 'RIDE-1108-A104',
    bikeId: 'BK-042',
    startedAt: DateTime(2026, 8, 11, 8, 10),
    endedAt: DateTime(2026, 8, 11, 8, 28, 32),
    startStation: RideStation.centralStation,
    endStation: RideStation.universityGate,
    distanceKm: 4.6,
    payment: const RidePaymentBreakdown(
      deposit: 20,
      unlockFee: 1.5,
      perMinuteRate: 0.2,
      startedMinutes: 19,
      maskedPaymentMethod: 'Visa •••• 4242',
    ),
  ),
  RideHistoryEntry(
    rideId: 'RIDE-0908-B219',
    bikeId: 'BK-118',
    startedAt: DateTime(2026, 8, 9, 17, 42),
    endedAt: DateTime(2026, 8, 9, 17, 54, 14),
    startStation: RideStation.riversidePark,
    endStation: RideStation.marketSquare,
    distanceKm: 3.1,
    payment: const RidePaymentBreakdown(
      deposit: 20,
      unlockFee: 1.5,
      perMinuteRate: 0.2,
      startedMinutes: 13,
      maskedPaymentMethod: 'Visa •••• 4242',
    ),
  ),
  RideHistoryEntry(
    rideId: 'RIDE-0408-C087',
    bikeId: 'BK-076',
    startedAt: DateTime(2026, 8, 4, 7, 55),
    endedAt: DateTime(2026, 8, 4, 8, 22, 5),
    startStation: RideStation.libraryStation,
    endStation: RideStation.centralStation,
    distanceKm: 6.8,
    payment: const RidePaymentBreakdown(
      deposit: 20,
      unlockFee: 1.5,
      perMinuteRate: 0.2,
      startedMinutes: 28,
      maskedPaymentMethod: 'Visa •••• 4242',
    ),
  ),
  RideHistoryEntry(
    rideId: 'RIDE-2807-D331',
    bikeId: 'BK-205',
    startedAt: DateTime(2026, 7, 28, 18, 6),
    endedAt: DateTime(2026, 7, 28, 18, 15, 40),
    startStation: RideStation.mainGate,
    endStation: RideStation.riversidePark,
    distanceKm: 2.2,
    payment: const RidePaymentBreakdown(
      deposit: 20,
      unlockFee: 1.5,
      perMinuteRate: 0.2,
      startedMinutes: 10,
      maskedPaymentMethod: 'Visa •••• 4242',
    ),
  ),
]);
