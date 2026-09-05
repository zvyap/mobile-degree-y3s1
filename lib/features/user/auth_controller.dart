import 'package:flutter/foundation.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/user/user_models.dart';
import 'package:bike_renting_app/data/repositories/auth_repository.dart';
//                                  supabase auth stuff in here ^^^


class AuthController extends ChangeNotifier {
  AuthController(
      this._authRepository,
      );

  final AuthRepository _authRepository;

  bool isBusy = false;
  UserError? error;
  UserProfileRecord? profile;

  bool get isAuthenticated => _authRepository.currentSession != null;
  String? get currentUserId => _authRepository.currentUser?.id;

  Future<void> login({required String email, required String password, }) async {
    error = null;

    if (email.trim().isEmpty) {
      error = UserError.emailRequired;
      notifyListeners();
      return;
    }

    if (password.isEmpty) {
      error = UserError.passwordRequired;
      notifyListeners();
      return;
    }

    _beginBusy();

    try {
      await _authRepository.login( //  debugging var: final response
        email: email.trim(),
        password: password,
      );
      // debugPrint('LOGIN SUCCESS: ${response.user?.email}');
      // debugPrint( 'SESSION EXISTS: ${response.session != null}', );

    } catch (e) {
      // debugPrint('Login error: $e');  test debug
      error = UserError.loginFailed; // issue here?
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (isBusy) return;

    _beginBusy();

    try {
      await _authRepository.logout();
      profile = null;
    } catch (caught) {
      error = UserError.logoutFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    error = null;

    final trimmedFirstName = firstName.trim();
    final trimmedLastName = lastName.trim();
    final trimmedEmail = email.trim();

    if (trimmedFirstName.isEmpty || trimmedLastName.isEmpty) {
      error = UserError.displayNameRequired;
      notifyListeners();
      return;
    }

    if (trimmedFirstName.length > 50 || trimmedLastName.length > 50) {
      error = UserError.registrationFailed;
      notifyListeners();
      return;
    }

    if (trimmedEmail.isEmpty) {
      error = UserError.emailRequired;
      notifyListeners();
      return;
    }

    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailRegex.hasMatch(trimmedEmail)) {
      error = UserError.invalidEmail;
      notifyListeners();
      return;
    }

    if (password.isEmpty) {
      error = UserError.passwordRequired;
      notifyListeners();
      return;
    }

    if (password.length < 8) {
      error = UserError.weakPassword;
      notifyListeners();
      return;
    }

    if (password != confirmPassword) {
      error = UserError.registrationFailed;
      notifyListeners();
      return;
    }

    _beginBusy();

    try {
      final displayName = '$trimmedFirstName $trimmedLastName';

      await _authRepository.register(
        email: trimmedEmail,
        password: password,
        displayName: displayName,
      );
    } catch (e) {
      error = UserError.registrationFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> forgotPassword({required String email,}) async {
    if (isBusy) return;
    error = null;

    if (email.trim().isEmpty) {
      error = UserError.emailRequired;
      notifyListeners();
      return;
    }
    _beginBusy();
    try {
      await _authRepository.resetPassword(
        email: email.trim(),
      );
    } catch (caught) {
      error = UserError.passwordResetFailed;

    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> updatePassword({
    required String password,
  }) async {
    if (isBusy) return;
    error = null;

    _beginBusy();

    try {
      await _authRepository.updatePassword(
        password: password,
      );
    } catch (caught) {
      error = UserError.passwordUpdateFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void _beginBusy() {
    isBusy = true;
    error = null;
    notifyListeners();
  }


}

