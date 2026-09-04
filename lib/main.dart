import 'package:bike_renting_app/app/bike_renting_app.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xlekizcdmynrngilkjoy.supabase.co',
    publishableKey: 'sb_publishable_JZzEqgEg8mOGEsZA8PzlNw_yhvdK-sn',
  );

  runApp(const BikeRentingApp());
}
