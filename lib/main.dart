import 'package:bike_renting_app/app/bike_renting_app.dart';
import 'package:bike_renting_app/shared/connection_blocked_screen.dart';
import 'package:bike_renting_app/shared/connection_service.dart';
import 'package:bike_renting_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

export 'package:bike_renting_app/shared/connection_blocked_screen.dart';
export 'package:bike_renting_app/shared/connection_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BikeRentingApp());
}

/// Blocking app UI displayed when internet or Supabase is unavailable.
/// Stops the user from accessing any app features until connection is verified.
class ConnectionBlockedApp extends StatelessWidget {
  const ConnectionBlockedApp({
    super.key,
    required this.reason,
    this.testInternet = testInternetConnection,
    this.testSupabase = testSupabaseConnection,
    this.onRetrySuccess,
  });

  final ConnectionFailureReason reason;
  final Future<bool> Function() testInternet;
  final Future<bool> Function() testSupabase;
  final Future<void> Function()? onRetrySuccess;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Connection Error',
      themeMode: ThemeMode.system,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      home: ConnectionBlockedScreen(
        initialReason: reason,
        testInternet: testInternet,
        testSupabase: testSupabase,
        onRetrySuccess: onRetrySuccess,
      ),
    );
  }
}
