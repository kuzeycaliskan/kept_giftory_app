import 'package:kept/core/error/failure.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Onboarding submit (G-12/G-13): availability check + profile creation.
@riverpod
class OnboardingController extends _$OnboardingController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// True when the username is free (used for inline feedback).
  Future<bool?> checkAvailability(String username) async {
    final result =
        await ref.read(profileRepositoryProvider).isUsernameAvailable(username);
    return result.when(success: (free) => free, failure: (_) => null);
  }

  /// Creates the profile; returns it on success, null on failure
  /// (error lands in [state]).
  Future<Profile?> submit({
    required String username,
    String? displayName,
    DateTime? birthday,
  }) async {
    state = const AsyncLoading();
    final result = await ref.read(profileRepositoryProvider).createProfile(
          username: username,
          displayName: displayName,
          birthday: birthday,
        );
    return result.when(
      success: (profile) {
        state = const AsyncData(null);
        ref.invalidate(myProfileProvider);
        return profile;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
    );
  }
}
