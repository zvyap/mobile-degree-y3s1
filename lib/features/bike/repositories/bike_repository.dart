import 'package:supabase_flutter/supabase_flutter.dart';

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

}