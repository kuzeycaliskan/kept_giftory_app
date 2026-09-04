import 'package:kept/core/error/result.dart';
import 'package:kept/features/profile/domain/profile.dart';

/// Profile data boundary (G-12/G-13).
abstract interface class ProfileRepository {
  /// The signed-in user's profile, or null if onboarding hasn't created it yet.
  Future<Result<Profile?>> fetchMyProfile();

  /// Case-insensitive availability check (G-12).
  Future<Result<bool>> isUsernameAvailable(String username);

  /// Creates the profile row during onboarding (G-13).
  Future<Result<Profile>> createProfile({
    required String username,
    String? displayName,
    DateTime? birthday,
  });

  Future<Result<Profile>> updateProfile(Profile profile);
}
