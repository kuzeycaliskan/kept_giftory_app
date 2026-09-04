import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/auth/application/dev_session.dart';
import 'package:kept/features/friends/data/dev_friendship_repository.dart';
import 'package:kept/features/friends/data/supabase_friendship_repository.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'friends_providers.g.dart';

@Riverpod(keepAlive: true)
FriendshipRepository friendshipRepository(Ref ref) {
  if (!Env.hasSupabaseConfig) return const EmptyFriendshipRepository();
  final client = ref.watch(supabaseClientProvider);
  if (ref.watch(devSessionProvider) && client.auth.currentUser == null) {
    return const DevFriendshipRepository();
  }
  return SupabaseFriendshipRepository(client);
}

/// All friendship rows for the Friends screen (friends + pending requests).
@riverpod
Future<List<FriendEntry>> friendEntries(Ref ref) async {
  final result = await ref.watch(friendshipRepositoryProvider).fetchAll();
  return result.when(
    success: (list) => list,
    failure: (failure) => throw failure,
  );
}

/// Mutations for the Friends screen; refreshes the list on success.
@riverpod
class FriendsController extends _$FriendsController {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> accept(String friendshipId) =>
      _run((repo) => repo.accept(friendshipId));

  Future<void> decline(String friendshipId) =>
      _run((repo) => repo.decline(friendshipId));

  Future<void> remove(String friendshipId) =>
      _run((repo) => repo.remove(friendshipId));

  Future<void> sendRequest(String profileId) =>
      _run((repo) => repo.sendRequest(profileId));

  Future<void> _run(
    Future<Result<void>> Function(FriendshipRepository repo) action,
  ) async {
    state = const AsyncLoading();
    final result = await action(ref.read(friendshipRepositoryProvider));
    result.when(
      success: (_) {
        state = const AsyncData(null);
        ref.invalidate(friendEntriesProvider);
      },
      failure: (Failure failure) {
        state = AsyncError(failure, StackTrace.current);
      },
    );
  }
}
