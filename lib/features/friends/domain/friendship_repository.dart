import 'package:kept/core/error/result.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';

/// Friendship boundary (G-31). RLS already scopes rows to the caller.
abstract interface class FriendshipRepository {
  /// Accepted friends + pending requests (both directions), for the Friends
  /// screen. Declined rows are not shown.
  Future<Result<List<FriendEntry>>> fetchAll();

  /// Send a request to [profileId] (G-32 search / G-33 matching hook).
  Future<Result<void>> sendRequest(String profileId);

  /// Accept an incoming request.
  Future<Result<void>> accept(String friendshipId);

  /// Decline an incoming request.
  Future<Result<void>> decline(String friendshipId);

  /// Remove a friend, or cancel an outgoing request.
  Future<Result<void>> remove(String friendshipId);
}
