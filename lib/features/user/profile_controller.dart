import 'package:flutter/foundation.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/user/user_models.dart';
import 'package:bike_renting_app/data/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._profileRepository);

  final ProfileRepository _profileRepository;

  bool isBusy = false;
  UserError? error;
  UserProfileRecord? profile;

  Future<void> loadProfile() async {
    if (isBusy) return;

    error = null;
    _beginBusy();

    try {
      profile = await _profileRepository.getCurrent();
    } catch (caught) {
      error = UserError.profileLoadFailed;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    required String displayName,
    String? phone,
    String? avatarUrl,
  }) async {
    if (isBusy) return;

    error = null;

    if (displayName.trim().isEmpty) {
      error = UserError.displayNameRequired;
      notifyListeners();
      return;
    }

    _beginBusy();

    try {
      profile = await _profileRepository.updateOwn(
        displayName: displayName.trim(),
        phone: phone?.trim(),
        avatarUrl: avatarUrl,
      );
    } catch (caught) {
      error = UserError.profileUpdateFailed;
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