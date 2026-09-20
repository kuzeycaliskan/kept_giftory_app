import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/events/domain/events_repository.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/features/gifts/data/gift_row_mapper.dart'
    show embeddedCount;
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/shared/data/profile_cards.dart';
import 'package:kept/shared/domain/comment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [EventsRepository]. Rows arrive already filtered by RLS
/// (members only, never the honoree); honoree + member identities resolve
/// through the discovery-card RPC so a private profile still has a name.
class SupabaseEventsRepository implements EventsRepository {
  SupabaseEventsRepository(this._client);

  final SupabaseClient _client;

  static const _select =
      'id, honoree_id, creator_id, event_date, reveal_at, status, '
      'external_chat_url, '
      'members:gift_event_members(user_id, role, status), '
      'comments:event_comments(count)';

  @override
  Future<Result<List<GiftEvent>>> fetchMine() async {
    if (_client.auth.currentUser == null) {
      return const ResultFailure(AuthFailure('Signed out'));
    }
    try {
      final rows = await _client
          .from('gift_events')
          .select(_select)
          .neq('status', 'cancelled')
          .order('event_date', ascending: true);
      return Success(await _resolve(rows.map(_bare).toList()));
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<GiftEvent?>> fetchEvent(String eventId) async {
    try {
      final row = await _client
          .from('gift_events')
          .select(_select)
          .eq('id', eventId)
          .maybeSingle();
      if (row == null) return const Success(null);
      final resolved = await _resolve([_bare(row)]);
      return Success(resolved.single);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  GiftEvent _bare(Map<String, dynamic> row) => GiftEvent(
    id: row['id']! as String,
    honoreeId: row['honoree_id']! as String,
    creatorId: row['creator_id'] as String?,
    eventDate: DateTime.parse(row['event_date']! as String),
    revealAt: DateTime.parse(row['reveal_at']! as String),
    status: EventStatus.values.byName(row['status']! as String),
    externalChatUrl: row['external_chat_url'] as String?,
    commentCount: embeddedCount(row['comments']),
    members: [
      for (final m
          in (row['members'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>())
        EventMember(
          userId: m['user_id']! as String,
          role: EventMemberRole.values.byName(m['role']! as String),
          status: EventMemberStatus.values.byName(m['status']! as String),
        ),
    ],
  );

  /// One card lookup for every honoree + member in the batch.
  Future<List<GiftEvent>> _resolve(List<GiftEvent> events) async {
    final cards = await fetchProfileCards(_client, [
      for (final e in events) ...[
        e.honoreeId,
        ...e.members.map((m) => m.userId),
      ],
    ]);
    return [
      for (final e in events)
        e.copyWith(
          honoree: cards[e.honoreeId],
          members: [
            for (final m in e.members)
              EventMember(
                userId: m.userId,
                role: m.role,
                status: m.status,
                user: cards[m.userId],
              ),
          ],
        ),
    ];
  }

  @override
  Future<Result<String>> createOrJoin(String honoreeId) async {
    try {
      final id = await _client.rpc<String>(
        'create_gift_event',
        params: {'p_honoree': honoreeId},
      );
      return Success(id);
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        return const ResultFailure(PermissionFailure('Not a friend'));
      }
      if (e.code == '23514') {
        return const ResultFailure(ValidationFailure('No birthday'));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<EventForHonoree?>> eventForHonoree(String honoreeId) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'gift_event_for_honoree',
        params: {'p_honoree': honoreeId},
      );
      final row = rows.firstOrNull as Map<String, dynamic>?;
      if (row == null) return const Success(null);
      final status = row['my_status'] as String?;
      return Success(
        EventForHonoree(
          eventId: row['event_id']! as String,
          eventDate: DateTime.parse(row['event_date']! as String),
          myStatus: status == null
              ? null
              : EventMemberStatus.values.byName(status),
        ),
      );
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ProfileCard>>> invitableFriends(String eventId) async {
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'event_invitable_friends',
        params: {'p_event': eventId},
      );
      return Success([
        for (final r in rows.cast<Map<String, dynamic>>())
          ProfileCard.fromJson(r),
      ]);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> invite(String eventId, String userId) async {
    try {
      await _client.rpc<void>(
        'invite_to_gift_event',
        params: {'p_event': eventId, 'p_user': userId},
      );
      return const Success(null);
    } on PostgrestException catch (e) {
      if (e.code == '42501') {
        return const ResultFailure(PermissionFailure('Cannot invite'));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> respond(String eventId, {required bool join}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      await _client
          .from('gift_event_members')
          .update({'status': join ? 'joined' : 'declined'})
          .eq('event_id', eventId)
          .eq('user_id', userId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> leave(String eventId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      await _client
          .from('gift_event_members')
          .delete()
          .eq('event_id', eventId)
          .eq('user_id', userId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> cancel(String eventId) =>
      _update(eventId, {'status': 'cancelled'});

  @override
  Future<Result<void>> setChatUrl(String eventId, String? url) =>
      _update(eventId, {'external_chat_url': url});

  Future<Result<void>> _update(
    String eventId,
    Map<String, dynamic> patch,
  ) async {
    try {
      await _client.from('gift_events').update(patch).eq('id', eventId);
      return const Success(null);
    } on PostgrestException catch (e) {
      if (e.code == '23514') {
        return const ResultFailure(ValidationFailure('Invalid link'));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  static const _commentSelect = 'id, author_id, body, created_at';

  @override
  Future<Result<List<Comment>>> fetchComments(String eventId) async {
    try {
      final rows = await _client
          .from('event_comments')
          .select(_commentSelect)
          .eq('event_id', eventId)
          .order('created_at', ascending: true);
      final comments = rows.map(Comment.fromJson).toList();
      final cards = await fetchProfileCards(
        _client,
        comments.map((c) => c.authorId),
      );
      return Success([
        for (final c in comments) c.copyWith(user: cards[c.authorId]),
      ]);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Comment>> addComment(String eventId, String body) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    final trimmed = body.trim();
    if (trimmed.isEmpty || trimmed.length > commentMaxLength) {
      return const ResultFailure(ValidationFailure('Invalid comment'));
    }
    try {
      final row = await _client
          .from('event_comments')
          .insert({'event_id': eventId, 'author_id': userId, 'body': trimmed})
          .select(_commentSelect)
          .single();
      return Success(Comment.fromJson(row));
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteComment(String commentId) async {
    try {
      await _client.from('event_comments').delete().eq('id', commentId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}

/// Backend-less runs (no --dart-define config).
class EmptyEventsRepository implements EventsRepository {
  const EmptyEventsRepository();

  static const _offline = ResultFailure<Never>(
    NetworkFailure('No backend configured'),
  );

  @override
  Future<Result<List<GiftEvent>>> fetchMine() async => const Success([]);

  @override
  Future<Result<GiftEvent?>> fetchEvent(String eventId) async =>
      const Success(null);

  @override
  Future<Result<String>> createOrJoin(String honoreeId) async => _offline;

  @override
  Future<Result<EventForHonoree?>> eventForHonoree(String honoreeId) async =>
      const Success(null);

  @override
  Future<Result<List<ProfileCard>>> invitableFriends(String eventId) async =>
      const Success([]);

  @override
  Future<Result<void>> invite(String eventId, String userId) async => _offline;

  @override
  Future<Result<void>> respond(String eventId, {required bool join}) async =>
      _offline;

  @override
  Future<Result<void>> leave(String eventId) async => _offline;

  @override
  Future<Result<void>> cancel(String eventId) async => _offline;

  @override
  Future<Result<void>> setChatUrl(String eventId, String? url) async =>
      _offline;

  @override
  Future<Result<List<Comment>>> fetchComments(String eventId) async =>
      const Success([]);

  @override
  Future<Result<Comment>> addComment(String eventId, String body) async =>
      _offline;

  @override
  Future<Result<void>> deleteComment(String commentId) async => _offline;
}
