import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/invite/data/dev_invite_repository.dart';
import 'package:kept/features/invite/data/supabase_invite_repository.dart';
import 'package:kept/features/invite/domain/invite_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'invite_providers.g.dart';

@Riverpod(keepAlive: true)
InviteRepository inviteRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyInviteRepository();
  final client = ref.watch(supabaseClientProvider);
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    return const DevInviteRepository();
  }
  return SupabaseInviteRepository(client);
}

@riverpod
Future<String> myInviteCode(Ref ref) async {
  final result = await ref.watch(inviteRepositoryProvider).fetchMyCode();
  return result.when(
    success: (code) => code,
    failure: (failure) => throw failure,
  );
}

@riverpod
class InviteController extends _$InviteController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// The new friend's label on success, null on failure (error in [state]).
  Future<String?> redeem(String code) async {
    state = const AsyncLoading();
    final result = await ref.read(inviteRepositoryProvider).redeem(code);
    return result.when(
      success: (redeemed) {
        state = const AsyncData(null);
        ref.invalidate(friendEntriesProvider);
        return redeemed.label;
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
        return null;
      },
    );
  }
}
