import 'package:kept/core/error/failure.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'privacy_settings_controller.g.dart';

/// Which profile section a visibility change targets (G-22).
enum PrivacySection { profile, wishlist, giftHistory }

/// Applies section-visibility changes (G-22). The screen reads current values
/// from [myProfileProvider]; this controller only performs the mutation and
/// refreshes that provider so every consumer sees the new setting at once.
@riverpod
class PrivacySettingsController extends _$PrivacySettingsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> setVisibility(PrivacySection section, Visibility value) async {
    state = const AsyncLoading();
    final repository = ref.read(profileRepositoryProvider);
    final result = await repository.updateVisibility(
      profile: section == PrivacySection.profile ? value : null,
      wishlist: section == PrivacySection.wishlist ? value : null,
      giftHistory: section == PrivacySection.giftHistory ? value : null,
    );
    result.when(
      success: (_) {
        ref.invalidate(myProfileProvider);
        state = const AsyncData(null);
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
      },
    );
  }
}
