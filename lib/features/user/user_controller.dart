import 'package:flutter/foundation.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/user/user_models.dart';
import 'package:bike_renting_app/data/repositories/profile_repository.dart';

class UserController extends ChangeNotifier {
  UserController(this._profileRepository);

  final ProfileRepository _profileRepository;

  bool isBusy = false;
  UserError? error;
  String? debugError; // debug

  List<UserProfileRecord> users = [];
  UserProfileRecord? selectedUser;

  // =========================
  // LOAD USERS
  // =========================

  Future<void> loadUsers() async {
    if (isBusy) return;

    _beginBusy();

    try {
      users = await _profileRepository.getAllUsers();
    } catch (caught) {
      error = UserError.usersLoadFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // =========================
  // SELECT USER
  // =========================

  void selectUser(UserProfileRecord user) {
    selectedUser = user;
    error = null;
    notifyListeners();
  }

  Future<void> loadUser(String userId) async {
    if (isBusy) return;

    error = null;
    _beginBusy();

    try {
      selectedUser = await _profileRepository.findById(userId);
    } catch (caught) {
      error = UserError.usersLoadFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  void clearSelectedUser() {
    selectedUser = null;
    error = null;
    notifyListeners();
  }

  // =========================
  // UPDATE USER
  // =========================

  Future<void> updateUser({
    required String userId,
    required String displayName,
    String? phone,
    String? avatarUrl,
    AppUserRole? role,
    AccountStatus? accountStatus,

    // TODO: Add IC fields after database migration.
    // String? icNumber,
    // bool? icVerified,
  }) async {
    if (isBusy) return;

    debugError = null;
    error = null;

    if (displayName.trim().isEmpty) {
      error = UserError.displayNameRequired;
      notifyListeners();
      return;
    }

    _beginBusy();

    try {
      final updatedUser = await _profileRepository.updateUser(
        userId: userId,
        displayName: displayName.trim(),
        phone: phone?.trim(),
        avatarUrl: avatarUrl,
        role: role,
        accountStatus: accountStatus,

        // TODO: Pass IC fields after database migration.
        // icNumber: icNumber,
        // icVerified: icVerified,
      );

      // Update the user in the local list.
      final index = users.indexWhere((user) => user.id == userId);

      if (index != -1) {
        users[index] = updatedUser;
      }

      // Update selected user if it is the same user.
      if (selectedUser?.id == userId) {
        selectedUser = updatedUser;
      }
    } catch (caught, stackTrace) {
      debugError = caught.toString();

      debugPrint('UPDATE USER FAILED: $caught');
      debugPrintStack(stackTrace: stackTrace);

      error = UserError.userUpdateFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // =========================
  // DELETE USER
  // =========================

  Future<void> deleteUser(String userId) async {
    if (isBusy) return;

    error = null;
    _beginBusy();

    try {
      await _profileRepository.deleteUser(userId);

      users.removeWhere((user) => user.id == userId);

      if (selectedUser?.id == userId) {
        selectedUser = null;
      }
    } catch (caught) {
      error = UserError.userDeleteFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // =========================
  // VERIFY IC
  // =========================

  Future<void> verifyIc({
    required String userId,
    // TODO: Add IC image/file parameter after IC verification is implemented.
  }) async {
    if (isBusy) return;

    error = null;
    _beginBusy();

    try {
      // TODO: Implement IC verification.
      //
      // Planned flow:
      // 1. Receive/upload the user's IC image.
      // 2. Run face detection on the image.
      // 3. If a face is detected, consider the IC verification successful.
      // 4. Update icVerified = true after the database migration.
      //
      // This is face detection only, not face recognition or
      // identity matching.

    } catch (caught) {
      error = UserError.icVerificationFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // =========================
  // ADD USER
  // =========================

  Future<void> addUser({
    required String email,
    required String password,
    required String displayName,
    String? phone,
    AppUserRole? role,

    // TODO: Add IC fields after database migration.
    // String? icNumber,
    // bool? icVerified,
  }) async {
    if (isBusy) return;

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

    if (displayName.trim().isEmpty) {
      error = UserError.displayNameRequired;
      notifyListeners();
      return;
    }

    _beginBusy();

    try {
      // TODO: Implement admin user creation through a secure backend
      // / Supabase Edge Function.
      //
      // Do NOT create an auth user directly from Flutter using a
      // service-role key.
      //
      // The backend should:
      // 1. Create the user in Supabase Auth.
      // 2. Create/update the corresponding profile.
      // 3. Apply the selected role.
      //
      // After implementation, reload the user list:
      //
      // await loadUsers();

    } catch (caught) {
      error = UserError.userCreationFailed;
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
