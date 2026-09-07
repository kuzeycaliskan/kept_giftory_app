import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/safety/data/dev_safety_repository.dart';
import 'package:kept/features/safety/data/supabase_safety_repository.dart';
import 'package:kept/features/safety/domain/safety_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'safety_providers.g.dart';

@Riverpod(keepAlive: true)
SafetyRepository safetyRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptySafetyRepository();
  final client = ref.watch(supabaseClientProvider);
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    return const DevSafetyRepository();
  }
  return SupabaseSafetyRepository(client);
}

/// The caller's block list (Settings → Blocked users).
@riverpod
Future<List<ProfileCard>> blockedUsers(Ref ref) async {
  final result = await ref.watch(safetyRepositoryProvider).blockedUsers();
  return result.when(
    success: (cards) => cards,
    failure: (failure) => throw failure,
  );
}

/// Block / unblock / report actions. Blocking invalidates every provider
/// that could still be showing the (now invisible) counterpart.
@riverpod
class SafetyController extends _$SafetyController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<bool> block(String userId) => _run(() async {
    final result = await ref.read(safetyRepositoryProvider).block(userId);
    return result.when(
      success: (_) {
        ref
          ..invalidate(friendEntriesProvider)
          ..invalidate(userProfileProvider(userId))
          ..invalidate(profileCardProvider(userId))
          ..invalidate(blockedUsersProvider);
        return true;
      },
      failure: (Failure failure) => throw failure,
    );
  });

  Future<bool> unblock(String userId) => _run(() async {
    final result = await ref.read(safetyRepositoryProvider).unblock(userId);
    return result.when(
      success: (_) {
        ref
          ..invalidate(blockedUsersProvider)
          ..invalidate(userProfileProvider(userId))
          ..invalidate(profileCardProvider(userId));
        return true;
      },
      failure: (Failure failure) => throw failure,
    );
  });

  Future<bool> report(String userId, ReportReason reason, {String? details}) =>
      _run(() async {
        final result = await ref
            .read(safetyRepositoryProvider)
            .report(userId, reason, details: details);
        return result.when(
          success: (_) => true,
          failure: (Failure failure) => throw failure,
        );
      });

  /// Runs an action, mirroring it into [state]; returns false on failure so
  /// callers can keep dialogs open / skip navigation.
  Future<bool> _run(Future<bool> Function() action) async {
    state = const AsyncLoading();
    try {
      final ok = await action();
      state = const AsyncData(null);
      return ok;
    } on Failure catch (failure, stack) {
      state = AsyncError(failure, stack);
      return false;
    }
  }
}
