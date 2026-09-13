import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/home/domain/birthday_math.dart';
import 'package:kept/features/home/domain/home_feed_items.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [HomeRepository].
///
/// Friend ids come from `friendships` (RLS already limits rows to the caller),
/// then friend profiles are read subject to their own visibility policies —
/// a friend whose profile is hidden from us simply drops out of the list.
class SupabaseHomeRepository implements HomeRepository {
  SupabaseHomeRepository(this._client, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final SupabaseClient _client;
  final DateTime Function() _now;

  Future<List<String>> _acceptedFriendIds(String userId) async {
    final rows = await _client
        .from('friendships')
        .select('requester_id, addressee_id')
        .eq('status', 'accepted');
    return rows
        .map(
          (row) => row['requester_id'] == userId
              ? row['addressee_id']! as String
              : row['requester_id']! as String,
        )
        .toSet()
        .toList();
  }

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final friendIds = await _acceptedFriendIds(userId);
      if (friendIds.isEmpty) return const Success([]);

      final profileRows = await _client
          .from('profiles')
          .select('id, username, display_name, avatar_url, birthday')
          .inFilter('id', friendIds)
          .not('birthday', 'is', null);

      final today = _now();
      final upcoming = profileRows.map((row) {
        final birthday = DateTime.parse(row['birthday']! as String);
        return UpcomingBirthday(
          friendId: row['id']! as String,
          username: row['username']! as String,
          displayName: row['display_name'] as String?,
          avatarUrl: row['avatar_url'] as String?,
          birthday: birthday,
          daysUntil: daysUntilBirthday(birthday, today),
        );
      }).toList()..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

      return Success(upcoming.take(limit).toList());
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<FriendWishlistItem>>> recentFriendWishlistItems({
    int limit = 6,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final friendIds = await _acceptedFriendIds(userId);
      if (friendIds.isEmpty) return const Success([]);

      // RLS (can_view_wishlist) drops items whose owner hid their list.
      final rows = await _client
          .from('wishlist_items')
          .select(
            'id, title, created_at, '
            'owner:profiles(id, username, display_name)',
          )
          .inFilter('owner_id', friendIds)
          .order('created_at', ascending: false)
          .limit(limit);

      final items = <FriendWishlistItem>[];
      for (final row in rows) {
        final owner = row['owner'] as Map<String, dynamic>?;
        if (owner == null) continue; // owner profile hidden by RLS
        items.add(
          FriendWishlistItem(
            itemId: row['id']! as String,
            title: row['title']! as String,
            ownerId: owner['id']! as String,
            ownerUsername: owner['username']! as String,
            ownerDisplayName: owner['display_name'] as String?,
            createdAt: DateTime.parse(row['created_at']! as String),
          ),
        );
      }
      return Success(items);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<HomeEvent>>> recentEvents({int limit = 6}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      // New friendships (mine) — counterpart resolved via joined profiles.
      final friendshipRows = await _client
          .from('friendships')
          .select(
            'requester_id, addressee_id, responded_at, '
            'requester:profiles!friendships_requester_id_fkey'
            '(id, username, display_name), '
            'addressee:profiles!friendships_addressee_id_fkey'
            '(id, username, display_name)',
          )
          .eq('status', 'accepted')
          .not('responded_at', 'is', null)
          .order('responded_at', ascending: false)
          .limit(limit);

      // Gifts logged for me — unrevealed surprises are RLS-hidden entirely,
      // so every row that arrives is safe to show.
      final giftRows = await _client
          .from('gifts')
          .select(
            'created_at, '
            'giver:profiles!gifts_giver_id_fkey(id, username, display_name)',
          )
          .eq('recipient_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final events = <HomeEvent>[];
      for (final row in friendshipRows) {
        final incoming = row['requester_id'] != userId;
        final other =
            (incoming ? row['requester'] : row['addressee'])
                as Map<String, dynamic>?;
        events.add(
          HomeEvent(
            kind: HomeEventKind.friendAccepted,
            at: DateTime.parse(row['responded_at']! as String),
            actorId: other?['id'] as String?,
            actorLabel:
                (other?['display_name'] ?? other?['username']) as String?,
          ),
        );
      }
      for (final row in giftRows) {
        final giver = row['giver'] as Map<String, dynamic>?;
        events.add(
          HomeEvent(
            kind: HomeEventKind.giftReceived,
            at: DateTime.parse(row['created_at']! as String),
            actorId: giver?['id'] as String?,
            actorLabel:
                (giver?['display_name'] ?? giver?['username']) as String?,
          ),
        );
      }
      events.sort((a, b) => b.at.compareTo(a.at));
      return Success(events.take(limit).toList());
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
