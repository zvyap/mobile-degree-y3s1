import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

const String supabaseUrl = 'https://xlekizcdmynrngilkjoy.supabase.co';
const String supabasePublishableKey =
    'sb_publishable_JZzEqgEg8mOGEsZA8PzlNw_yhvdK-sn';

enum ConnectionFailureReason {
  noInternet,
  noSupabase,
}

/// Tests whether the device has a working internet connection.
Future<bool> testInternetConnection({
  Duration timeout = const Duration(seconds: 4),
  http.Client? httpClient,
}) async {
  try {
    final lookup = await InternetAddress.lookup('google.com').timeout(timeout);
    if (lookup.isNotEmpty && lookup[0].rawAddress.isNotEmpty) {
      debugPrint('[ConnectionTest] Internet DNS check: PASSED');
      return true;
    }
  } catch (e) {
    debugPrint('[ConnectionTest] Internet DNS check failed: $e');
  }

  final client = httpClient ?? http.Client();
  try {
    final response = await client
        .get(Uri.parse('https://clients3.google.com/generate_204'))
        .timeout(timeout);
    final isSuccess = response.statusCode == 204 || response.statusCode == 200;
    debugPrint(
      '[ConnectionTest] Internet HTTP check: ${isSuccess ? "PASSED" : "FAILED"}',
    );
    return isSuccess;
  } catch (e) {
    debugPrint('[ConnectionTest] Internet HTTP check failed: $e');
    return false;
  } finally {
    if (httpClient == null) {
      client.close();
    }
  }
}

/// Tests whether the Supabase backend service is reachable and healthy.
Future<bool> testSupabaseConnection({
  Duration timeout = const Duration(seconds: 4),
  http.Client? httpClient,
  String url = supabaseUrl,
  String apiKey = supabasePublishableKey,
}) async {
  final client = httpClient ?? http.Client();
  try {
    final response = await client.get(
      Uri.parse('$url/auth/v1/health'),
      headers: {
        'apikey': apiKey,
      },
    ).timeout(timeout);
    final isSuccess = response.statusCode == 200;
    debugPrint(
      '[ConnectionTest] Supabase health check: ${isSuccess ? "PASSED" : "FAILED (${response.statusCode})"}',
    );
    return isSuccess;
  } catch (e) {
    debugPrint('[ConnectionTest] Supabase health check failed: $e');
    return false;
  } finally {
    if (httpClient == null) {
      client.close();
    }
  }
}

/// Ensures Supabase is initialized safely without duplicate initialization.
Future<void> ensureSupabaseInitialized({
  String url = supabaseUrl,
  String apiKey = supabasePublishableKey,
}) async {
  try {
    Supabase.instance.client;
  } catch (_) {
    await Supabase.initialize(
      url: url,
      publishableKey: apiKey,
    );
  }
}
