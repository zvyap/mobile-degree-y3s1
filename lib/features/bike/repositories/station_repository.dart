import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/station.dart';

class StationRepository {
  final SupabaseClient _supabase;

  StationRepository({
    SupabaseClient? supabase,
  }) : _supabase =
      supabase ?? Supabase.instance.client;

  Future<List<Station>> getStations() async {
    final response = await _supabase
        .from('stations')
        .select('id, code, name')
        .order('name');

    return response
        .map<Station>(
          (json) => Station.fromJson(json),
    )
        .toList();
  }
}