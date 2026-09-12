import 'package:kept/core/error/failure.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_profile_controller.g.dart';

/// Saves profile edits (G-23). Success refreshes [myProfileProvider] so the
/// Me screen and every other consumer re-render at once.
@riverpod
class EditProfileController extends _$EditProfileController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Returns true on success. A [ValidationFailure] (taken/invalid username)
  /// stays in [state] for the form to map to a field error.
  Future<bool> save(Profile edited) async {
    state = const AsyncLoading();
    final result = await ref
        .read(profileRepositoryProvider)
        .updateProfile(edited);
    return result.when(
      success: (_) {
        ref.invalidate(myProfileProvider);
        state = const AsyncData(null);
        return true;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return false;
      },
    );
  }
}
