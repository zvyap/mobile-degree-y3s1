import 'package:bike_renting_app/data/models/database_models.dart';

class RentalSessionSnapshot {
  const RentalSessionSnapshot({
    required this.rental,
    required this.bike,
    required this.startStation,
    this.endStation,
  });

  final RentalDatabaseRecord rental;
  final BikeDatabaseRecord bike;
  final StationAvailabilityRecord startStation;
  final StationAvailabilityRecord? endStation;
}
