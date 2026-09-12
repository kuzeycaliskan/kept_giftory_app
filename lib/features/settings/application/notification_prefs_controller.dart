import 'package:kept/core/error/failure.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'notification_prefs_controller.g.dart';

/// Applies notification-preference changes (G-63). Values are read from
/// [myProfileProvider]; a successful update refreshes it so every consumer
/// sees the new setting.
@riverpod
class NotificationPrefsController extends _$NotificationPrefsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> setBirthdayReminders({required bool enabled}) async {
    state = const AsyncLoading();
    final result = await ref
        .read(profileRepositoryProvider)
        .setBirthdayReminders(enabled: enabled);
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
