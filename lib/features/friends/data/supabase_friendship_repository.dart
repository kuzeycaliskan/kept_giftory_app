import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/friends/domain/friendship_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [FriendshipRepository].
///
/// Uses embedded selects on both FK sides; the "other" party is resolved
/// client-side. Profiles hidden by RLS come back null and the row is dropped
/// (with the pending-visibility policy this only happens in edge cases).
class SupabaseFriendshipRepository implements FriendshipRepository {
  SupabaseFriendshipRepository(this._client);

  final SupabaseClient _client;

  static const _select = 'id, status, requester_id, addressee_id, '
      'requester:profiles!friendships_requester_id_fkey'
      '(id, username, display_name, avatar_url), '
      'addressee:profiles!friendships_addressee_id_fkey'
      '(id, username, display_name, avatar_url)';

  @override
  Future<Result<List<FriendEntry>>> fetchAll() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final rows = await _client
          .from('friendships')
          .select(_select)
          .inFilter('status', ['pending', 'accepted']);

      final entries = <FriendEntry>[];
      for (final row in rows) {
        final requesterId = row['requester_id']! as String;
        final incoming = requesterId != userId;
        final other = (incoming ? row['requester'] : row['addressee'])
            as Map<String, dynamic>?;
        if (other == null) continue; // other profile hidden by RLS
        final status = row['status'] == 'accepted'
            ? FriendshipStatus.accepted
            : FriendshipStatus.pending;
        entries.add(
          FriendEntry(
            friendshipId: row['id']! as String,
            profileId: other['id']! as String,
            username: other['username']! as String,
            displayName: other['display_name'] as String?,
            avatarUrl: other['avatar_url'] as String?,
            status: status,
            direction: status == FriendshipStatus.pending
                ? (incoming
                    ? RequestDirection.incoming
                    : RequestDirection.outgoing)
                : null,
          ),
        );
      }
      return Success(entries);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> sendRequest(String profileId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      await _client.from('friendships').insert({
        'requester_id': userId,
        'addressee_id': profileId,
      });
      return const Success(null);
    } on PostgrestException catch (e) {
      // 23505 = unique pair violation → a relationship already exists.
      if (e.code == '23505') {
        return const ResultFailure(
          ValidationFailure('Relationship already exists'),
        );
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> accept(String friendshipId) =>
      _respond(friendshipId, 'accepted');

  @override
  Future<Result<void>> decline(String friendshipId) =>
      _respond(friendshipId, 'declined');

  Future<Result<void>> _respond(String friendshipId, String status) async {
    try {
      await _client
          .from('friendships')
          .update({
            'status': status,
            'responded_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', friendshipId)
          .eq('status', 'pending');
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> remove(String friendshipId) async {
    try {
      await _client.from('friendships').delete().eq('id', friendshipId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
