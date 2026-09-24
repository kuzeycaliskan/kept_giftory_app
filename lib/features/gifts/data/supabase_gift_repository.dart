import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/media/media_store.dart';
import 'package:kept/features/gifts/data/gift_row_mapper.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/domain/gift_repository.dart';
import 'package:kept/shared/data/profile_cards.dart';
import 'package:kept/shared/domain/comment.dart';
import 'package:kept/shared/domain/reaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [GiftRepository]. Counterpart profiles come via embedded
/// selects; a null giver embed = anonymized (deleted) giver.
class SupabaseGiftRepository implements GiftRepository {
  SupabaseGiftRepository(this._client, this._media);

  final SupabaseClient _client;
  final MediaStore _media;

  static const _giverSelect =
      'id, item, note, gift_date, is_surprise, giver_relation, '
      'reveal_at, giver_id, recipient_id, '
      'giver:profiles!gifts_giver_id_fkey(id, username, display_name), '
      '$giftEmbeds';
  static const _recipientSelect =
      'id, item, note, gift_date, is_surprise, giver_relation, '
      'reveal_at, giver_id, recipient_id, '
      'recipient:profiles!gifts_recipient_id_fkey(id, username, display_name), '
      '$giftEmbeds';

  @override
  Future<Result<List<GiftEntry>>> fetchGiven() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final rows = await _client
          .from('gifts')
          .select(_recipientSelect)
          .eq('giver_id', userId)
          .order('gift_date', ascending: false);
      return Success(
        await resolveReactionCards(_client, [
          for (final r in rows)
            giftEntryFromRow(r, counterpartKey: 'recipient'),
        ]),
      );
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<GiftEntry>>> fetchReceived() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    return _historyOf(userId);
  }

  @override
  Future<Result<List<GiftEntry>>> fetchFor(String profileId) =>
      _historyOf(profileId);

  Future<Result<List<GiftEntry>>> _historyOf(String recipientId) async {
    try {
      final rows = await _client
          .from('gifts')
          .select(_giverSelect)
          .eq('recipient_id', recipientId)
          .order('gift_date', ascending: false);
      return Success(
        await resolveReactionCards(_client, [
          for (final r in rows) giftEntryFromRow(r, counterpartKey: 'giver'),
        ]),
      );
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<GiftEntry>> log({
    required String recipientId,
    required String item,
    required DateTime giftDate,
    required bool isSurprise,
    String? note,
    DateTime? revealAt,
    String? linkPreviewId,
    String? eventId,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    final trimmed = item.trim();
    if (trimmed.isEmpty || trimmed.length > 200) {
      return const ResultFailure(ValidationFailure('Invalid item'));
    }
    if (isSurprise && revealAt == null) {
      return const ResultFailure(ValidationFailure('Reveal date required'));
    }
    try {
      final row = await _client
          .from('gifts')
          .insert({
            'giver_id': userId,
            'recipient_id': recipientId,
            'item': trimmed,
            'gift_date': giftDate.toIso8601String().substring(0, 10),
            'is_surprise': isSurprise,
            if (isSurprise) 'reveal_at': revealAt!.toUtc().toIso8601String(),
            if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
            if (linkPreviewId != null) 'link_preview_id': linkPreviewId,
            if (eventId != null) 'event_id': eventId,
          })
          .select(_recipientSelect)
          .single();
      return Success(giftEntryFromRow(row, counterpartKey: 'recipient'));
    } on PostgrestException catch (e) {
      if (e.code == '23514') {
        return const ResultFailure(ValidationFailure('Invalid gift'));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<GiftEntry>> logExternal({
    required GiftRelation relation,
    required String item,
    required DateTime giftDate,
    String? note,
    String? linkPreviewId,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    final trimmed = item.trim();
    if (trimmed.isEmpty || trimmed.length > 200) {
      return const ResultFailure(ValidationFailure('Invalid item'));
    }
    try {
      final row = await _client
          .from('gifts')
          .insert({
            'recipient_id': userId,
            'giver_relation': relation.name,
            'item': trimmed,
            'gift_date': giftDate.toIso8601String().substring(0, 10),
            'is_surprise': false,
            if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
            if (linkPreviewId != null) 'link_preview_id': linkPreviewId,
          })
          .select(_giverSelect)
          .single();
      return Success(giftEntryFromRow(row, counterpartKey: 'giver'));
    } on PostgrestException catch (e) {
      if (e.code == '23514') {
        return const ResultFailure(ValidationFailure('Invalid gift'));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> delete(String giftId) async {
    try {
      await _client.from('gifts').delete().eq('id', giftId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<GiftEntry?>> fetchGift(
    String giftId, {
    required bool counterpartIsGiver,
  }) async {
    try {
      final row = await _client
          .from('gifts')
          .select(counterpartIsGiver ? _giverSelect : _recipientSelect)
          .eq('id', giftId)
          .maybeSingle();
      if (row == null) return const Success(null);
      return Success(
        giftEntryFromRow(
          row,
          counterpartKey: counterpartIsGiver ? 'giver' : 'recipient',
        ),
      );
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<GiftPhoto>> addPhoto({
    required String giftId,
    required Uint8List jpegBytes,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));

    final path = '$userId/$giftId-${DateTime.now().microsecondsSinceEpoch}.jpg';
    final uploaded = await _media.upload(
      bucket: giftMediaBucket,
      path: path,
      bytes: jpegBytes,
      contentType: 'image/jpeg',
    );
    final uploadFailure = uploaded.when<Failure?>(
      success: (_) => null,
      failure: (f) => f,
    );
    if (uploadFailure != null) return ResultFailure(uploadFailure);

    try {
      final row = await _client
          .from('gift_photos')
          .insert({
            'gift_id': giftId,
            'uploader_id': userId,
            'media_path': path,
          })
          .select('id, gift_id, uploader_id, media_path, created_at')
          .single();
      return Success(giftPhotosFromRows([row]).single);
    } on PostgrestException catch (e) {
      // No row → nobody can ever see the object; roll the upload back.
      await _media.delete(bucket: giftMediaBucket, path: path);
      if (e.code == '23514') {
        return const ResultFailure(ValidationFailure('Photo cap reached'));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      await _media.delete(bucket: giftMediaBucket, path: path);
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> removePhoto(GiftPhoto photo) async {
    try {
      await _media.delete(bucket: giftMediaBucket, path: photo.mediaPath);
      await _client.from('gift_photos').delete().eq('id', photo.id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setReaction(String giftId, ReactionKind kind) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      await _client.from('gift_reactions').upsert({
        'gift_id': giftId,
        'user_id': userId,
        'kind': kind.name,
      });
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> clearReaction(String giftId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      await _client
          .from('gift_reactions')
          .delete()
          .eq('gift_id', giftId)
          .eq('user_id', userId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  static const _commentSelect = 'id, author_id, body, created_at';

  @override
  Future<Result<List<Comment>>> fetchComments(String giftId) async {
    try {
      final rows = await _client
          .from('gift_comments')
          .select(_commentSelect)
          .eq('gift_id', giftId)
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
  Future<Result<Comment>> addComment(String giftId, String body) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    final trimmed = body.trim();
    if (trimmed.isEmpty || trimmed.length > commentMaxLength) {
      return const ResultFailure(ValidationFailure('Invalid comment'));
    }
    try {
      final row = await _client
          .from('gift_comments')
          .insert({'gift_id': giftId, 'author_id': userId, 'body': trimmed})
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
      await _client.from('gift_comments').delete().eq('id', commentId);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
