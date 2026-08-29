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
    final currentEmail = _client.auth.currentUser?.email?.toLowerCase();
    if (currentEmail == email) return;

    if (_client.auth.currentSession != null) await _client.auth.signOut();
    await _client.auth.signInWithPassword(email: email, password: password);

    // TODO(auth): Replace automatic demo login with the future User module's
    // authenticated rider session. Never reuse these credentials in production.
  }
}
