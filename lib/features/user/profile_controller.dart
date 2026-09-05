import 'package:flutter/foundation.dart';
import 'package:bike_renting_app/data/models/database_models.dart';
import 'package:bike_renting_app/features/user/user_models.dart';
import 'package:bike_renting_app/data/repositories/profile_repository.dart';
import 'package:bike_renting_app/bike_station/supabase_storage_service.dart';
import 'dart:io';

import 'package:flutter/material.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._profileRepository) : _storageService = SupabaseStorageService();

  final ProfileRepository _profileRepository;
  final SupabaseStorageService _storageService;

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

  Future<void> uploadAvatar({
    required String userId,
    required File image,
  }) async {
    if (isBusy) return;

    error = null;
    _beginBusy();

    try {
      // 1. Upload image to Storage and get its public URL.
      final avatarUrl = await _storageService.uploadWebpImage(
        imageInput: image,
        bucketName: 'app-uploads',
        folderPath: 'avatars',
        customFileName: '$userId.webp',
        quality: 80,
      );


      if (avatarUrl == null || avatarUrl.isEmpty) {
        throw Exception('Avatar upload returned no URL.');
      }

      final currentProfile = profile;

      if (currentProfile == null) {
        throw Exception('Profile is not loaded.');
      }

      // 2. Save that URL into profiles.avatar_url.
      profile = await _profileRepository.updateOwn(
        displayName: currentProfile.displayName,
        phone: currentProfile.phone,
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