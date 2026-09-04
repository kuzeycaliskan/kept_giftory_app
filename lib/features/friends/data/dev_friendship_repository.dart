import 'package:kept/core/error/result.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';

/// Sample entries for the debug-only dev session; mutations are no-ops that
/// succeed so UI flows are walkable. Never used in release flows.
class DevFriendshipRepository implements FriendshipRepository {
  const DevFriendshipRepository();

  @override
  Future<Result<List<FriendEntry>>> fetchAll() async => const Success([
        FriendEntry(
          friendshipId: 'dev-f1',
          profileId: 'dev-ali',
          username: 'ali',
          displayName: 'Ali',
          status: FriendshipStatus.accepted,
        ),
        FriendEntry(
          friendshipId: 'dev-f2',
          profileId: 'dev-zeynep',
          username: 'zeynep',
          displayName: 'Zeynep',
          status: FriendshipStatus.accepted,
        ),
        FriendEntry(
          friendshipId: 'dev-f3',
          profileId: 'dev-selin',
          username: 'selin',
          displayName: 'Selin',
          status: FriendshipStatus.pending,
          direction: RequestDirection.incoming,
        ),
        FriendEntry(
          friendshipId: 'dev-f4',
          profileId: 'dev-mert',
          username: 'mert',
          displayName: 'Mert',
          status: FriendshipStatus.pending,
          direction: RequestDirection.outgoing,
        ),
      ]);

  @override
  Future<Result<void>> sendRequest(String profileId) async =>
      const Success(null);

  @override
  Future<Result<void>> accept(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> decline(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> remove(String friendshipId) async =>
      const Success(null);
}

/// Backend-less fallback (no --dart-define config).
class EmptyFriendshipRepository implements FriendshipRepository {
  const EmptyFriendshipRepository();

  @override
  Future<Result<List<FriendEntry>>> fetchAll() async => const Success([]);

  @override
  Future<Result<void>> sendRequest(String profileId) async =>
      const Success(null);

  @override
  Future<Result<void>> accept(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> decline(String friendshipId) async =>
      const Success(null);

  @override
  Future<Result<void>> remove(String friendshipId) async =>
      const Success(null);
}
