import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bike_performance.dart';
import '../models/bike.dart';

class BikeRepository {
  final SupabaseClient _supabase;

  BikeRepository({
    SupabaseClient? supabase,
  }) : _supabase =
      supabase ?? Supabase.instance.client;

  Future<List<Bike>> getBikes() async {
    final response = await _supabase
        .from('bikes')
        .select('''
          id,
          code,
          qr_token,
          current_station_id,
          battery_percent,
          status,
          last_service_at,
          stations (
            name
          )
        ''')
        .order('code');

    return response
        .map<Bike>(
          (json) => Bike.fromJson(json),
    )
        .toList();
  }

//for bikedetail page
  Future<Bike> getBike(int bikeId) async {
    final response = await _supabase
        .from('bikes')
        .select('''
        id,
        code,
        qr_token,
        current_station_id,
        battery_percent,
        status,
        last_service_at,
        stations (
          name
        )
      ''')
        .eq('id', bikeId)
        .single();

    return Bike.fromJson(response);
  }

  Future<void> addBike({
    required String code,
    required String qrToken,
    required String status,
    int? stationId,
    int? batteryPercent,
  }) async {
    await _supabase.from('bikes').insert({
      'code': code,
      'qr_token': qrToken,
      'current_station_id': stationId,
      'battery_percent': batteryPercent,
      'status': status,
    });
  }

  Future<void> updateBike({
    required int bikeId,
    required String code,
    required int batteryPercent,
    required String status,
  }) async {
    await _supabase
        .from('bikes')
        .update({
      'code': code,
      'battery_percent': batteryPercent,
      'status': status,
    })
        .eq('id', bikeId);
  }

  Future<void> transferBike({
    required int bikeId,
    required int stationId,
  }) async {
    await _supabase
        .from('bikes')
        .update({
      'current_station_id': stationId,
    })
        .eq('id', bikeId);
  }

  Future<void> startBikeService({
    required int bikeId,
  }) async {
    await _supabase
        .from('bikes')
        .update({
      'status': 'maintenance',
    })
        .eq('id', bikeId);
  }

  Future<void> completeBikeService({
    required int bikeId,
  }) async {
    await _supabase
        .from('bikes')
        .update({
      'status': 'available',
      'last_service_at':
      DateTime.now().toUtc().toIso8601String(),
    })
        .eq('id', bikeId);
  }
  Future<void> retireBike({
    required int bikeId,
  }) async {
    await _supabase
        .from('bikes')
        .update({
      'status': 'retired',
    })
        .eq('id', bikeId);
  }

  Future<BikePerformance> getBikePerformance(
      int bikeId,
      ) async {
    final response = await _supabase
        .from('rentals')
        .select('id, distance_km')
        .eq('bike_id', bikeId)
        .eq('status', 'completed');

    double totalDistance = 0;

    for (final rental in response) {
      final distance = rental['distance_km'];

      if (distance != null) {
        totalDistance += (distance as num).toDouble();
      }
    }

    return BikePerformance(
      rentalCount: response.length,
      totalDistanceKm: totalDistance,
    );
  }

}