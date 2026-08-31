import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class RentSessionAuthenticator {
  Future<void> ensureSignedIn();
}

class SupabaseRentAuthenticator implements RentSessionAuthenticator {
  SupabaseRentAuthenticator(this._client);

  final SupabaseClient _client;

  @override
  Future<void> ensureSignedIn() async {
    final currentSession = _client.auth.currentSession;
    if (currentSession == null || currentSession.isExpired) {
      throw const AuthException('User is not authenticated');
    }
  }
}
