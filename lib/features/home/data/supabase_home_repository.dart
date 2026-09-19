import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/gifts/data/gift_row_mapper.dart';
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

      // Gift posts: mine + friends'. My unrevealed surprises are RLS-hidden;
      // friends' pending surprises are filtered here (feed rule: a surprise
      // reaches the feed only once it opens — no accidental spoilers).
      final friendIds = await _acceptedFriendIds(userId);
      final nowIso = _now().toUtc().toIso8601String();
      final giftRows = await _client
          .from('gifts')
          .select(
            'id, item, note, gift_date, is_surprise, giver_relation, '
            'reveal_at, giver_id, recipient_id, created_at, '
            'giver:profiles!gifts_giver_id_fkey(id, username, display_name), '
            'recipient:profiles!gifts_recipient_id_fkey'
            '(id, username, display_name), '
            '$giftEmbeds',
          )
          .inFilter('recipient_id', [userId, ...friendIds])
          .or('is_surprise.eq.false,reveal_at.lte.$nowIso')
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
      final gifts = await resolveReactionCards(_client, [
        for (final row in giftRows)
          giftEntryFromRow(row, counterpartKey: 'giver'),
      ]);
      for (var i = 0; i < giftRows.length; i++) {
        final row = giftRows[i];
        final gift = gifts[i];
        final at = DateTime.parse(row['created_at']! as String);
        final recipient = row['recipient'] as Map<String, dynamic>?;
        final mine = gift.recipientId == userId;
        // Three giver states (G-212): member, external (relation), deleted
        // member (both null → anonymized "someone").
        events.add(
          !mine
              ? HomeEvent(
                  kind: HomeEventKind.friendGiftReceived,
                  at: at,
                  actorId: gift.counterpartId,
                  actorLabel: gift.counterpartLabel,
                  item: gift.item,
                  gift: gift,
                  recipientId: gift.recipientId,
                  recipientLabel:
                      (recipient?['display_name'] ?? recipient?['username'])
                          as String?,
                )
              : gift.giverRelation != null
              ? HomeEvent(
                  kind: HomeEventKind.externalGiftLogged,
                  at: at,
                  giverRelation: gift.giverRelation,
                  item: gift.item,
                  gift: gift,
                )
              : HomeEvent(
                  kind: HomeEventKind.giftReceived,
                  at: at,
                  actorId: gift.counterpartId,
                  actorLabel: gift.counterpartLabel,
                  item: gift.item,
                  gift: gift,
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

  @override
  Future<Result<SurpriseTeaser?>> surpriseTeaser() async {
    if (_client.auth.currentUser == null) {
      return const ResultFailure(AuthFailure('Signed out'));
    }
    try {
      final rows = await _client.rpc<List<dynamic>>('pending_surprise_teaser');
      final row = rows.firstOrNull as Map<String, dynamic>?;
      if (row == null || row['has_pending'] != true) return const Success(null);
      return Success(
        SurpriseTeaser(
          nextRevealAt: DateTime.parse(row['next_reveal_at']! as String),
        ),
      );
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
