import 'package:bike_renting_app/data/database/database_data_source.dart';
import 'package:bike_renting_app/data/repositories/bike_repository.dart';
import 'package:bike_renting_app/data/repositories/payment_method_repository.dart';
import 'package:bike_renting_app/data/repositories/profile_repository.dart';
import 'package:bike_renting_app/data/repositories/rental_repository.dart';
import 'package:bike_renting_app/data/repositories/station_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppRepositories {
  AppRepositories._(DatabaseDataSource dataSource)
    : profiles = ProfileRepository(dataSource),
      stations = StationRepository(dataSource),
      bikes = BikeRepository(dataSource),
      paymentMethods = PaymentMethodRepository(dataSource),
      rentals = RentalRepository(dataSource);

  factory AppRepositories.fromSupabase(SupabaseClient client) {
    return AppRepositories._(SupabaseDatabaseDataSource(client));
  }

  final ProfileRepository profiles;
  final StationRepository stations;
  final BikeRepository bikes;
  final PaymentMethodRepository paymentMethods;
  final RentalRepository rentals;
}
