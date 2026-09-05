import 'dart:math' as math;
import 'package:bike_renting_app/data/models/database_models.dart';

class AdminRentalSession {
  const AdminRentalSession({
    required this.rental,
    this.bike,
    this.startStation,
    this.endStation,
    this.user,
  });

  final RentalDatabaseRecord rental;
  final BikeDatabaseRecord? bike;
  final StationAvailabilityRecord? startStation;
  final StationAvailabilityRecord? endStation;
  final UserProfileRecord? user;

  int get id => rental.id;
  String get publicId => rental.publicId;
  RentalDatabaseStatus get status => rental.status;
  DateTime? get startedAt => rental.startedAt;
  DateTime? get returnRequestedAt => rental.returnRequestedAt;
  DateTime get createdAt => rental.createdAt;
  int get durationSeconds => rental.durationSeconds;
  double get distanceKm => rental.distanceKm;
  double get unlockFee => rental.unlockFee;
  double get perMinuteRate => rental.perMinuteRate;
  double get holdAmount => rental.holdAmount;
  String get currency => rental.currency;
  bool get isOverdue =>
      rental.overdueAt != null ||
      (rental.rideDeadlineAt != null && DateTime.now().isAfter(rental.rideDeadlineAt!));
  DateTime? get rideDeadlineAt => rental.rideDeadlineAt;
  DateTime? get overdueAt => rental.overdueAt;
  String? get failureReason => rental.failureReason;

  int currentElapsedSeconds([DateTime? now]) {
    if (rental.startedAt == null) return rental.durationSeconds;
    if (rental.endedAt != null ||
        rental.status == RentalDatabaseStatus.completed ||
        rental.status == RentalDatabaseStatus.cancelled ||
        rental.status == RentalDatabaseStatus.lost) {
      return rental.durationSeconds;
    }
    final currentTime = now ?? DateTime.now();
    return math.max(
      rental.durationSeconds,
      currentTime.difference(rental.startedAt!).inSeconds,
    );
  }

  double currentFare([DateTime? now]) {
    if (rental.finalFare != null) return rental.finalFare!;
    if (rental.startedAt == null) return 0.0;
    final seconds = currentElapsedSeconds(now);
    final minutes = math.max(1, (seconds / 60.0).ceil());
    return ((rental.unlockFee + (minutes * rental.perMinuteRate)) * 100).round() / 100;
  }
}
