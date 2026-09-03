import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/bike.dart';

class BikeRepository {
  final SupabaseClient _supabase;

  BikeRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Bike>> getBikes() async {
    final response = await _supabase
        .from('bikes')
        .select()
        .order('code');

    return response
        .map<Bike>((json) => Bike.fromJson(json))
        .toList();
  }

  Future<void> testBikeRetrieval() async {
    final response = await Supabase.instance.client
        .from('bikes')
        .select();

    print(response);
    print("gay");
  }
}