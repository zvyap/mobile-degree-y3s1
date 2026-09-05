import 'package:supabase_flutter/supabase_flutter.dart';
// supabase auth stuff happen here
class AuthRepository {
  SupabaseClient get _client => Supabase.instance.client;

  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    return await _client.auth.signUp( email: email, password: password, data: {'display_name': displayName});
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword( email: email,password: password, );
  }

  Future<void> resetPassword({
    required String email,
  }) async {
    await _client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'bike-renting://reset-password'
    );
  }

  Future<void> updatePassword({
    required String password,
  }) async {
    await _client.auth.updateUser(
      UserAttributes(
        password: password,
      ),
    );
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }
}