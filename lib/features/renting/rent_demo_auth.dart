import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class RentSessionAuthenticator {
  Future<void> ensureSignedIn();
}

class SupabaseDemoRentAuthenticator implements RentSessionAuthenticator {
  SupabaseDemoRentAuthenticator(this._client);

  static const email = 'renting.demo.01@example.com';
  static const password = 'BikeRenting-Demo-01!2026';

  final SupabaseClient _client;

  @override
  Future<void> ensureSignedIn() async {
    final currentSession = _client.auth.currentSession;
    if (currentSession != null && !currentSession.isExpired) {
      return;
    }

    await _client.auth.signInWithPassword(email: email, password: password);
  }
}
