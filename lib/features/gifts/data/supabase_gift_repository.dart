import 'package:flutter/foundation.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/core/media/media_store.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/domain/gift_repository.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [GiftRepository]. Counterpart profiles come via embedded
/// selects; a null giver embed = anonymized (deleted) giver.
class SupabaseGiftRepository implements GiftRepository {
  SupabaseGiftRepository(this._client, this._media);

  final SupabaseClient _client;
  final MediaStore _media;

  static const _photosSelect =
      'photos:gift_photos(id, gift_id, uploader_id, media_path, created_at)';

  static const _giverSelect =
      'id, item, note, gift_date, is_surprise, giver_relation, '
      'reveal_at, giver_id, recipient_id, '
      'giver:profiles!gifts_giver_id_fkey(id, username, display_name), '
      ' preview:link_previews(id, url, title, image_path, price, site), '
      '$_photosSelect';
  static const _recipientSelect =
      'id, item, note, gift_date, is_surprise, giver_relation, '
      'reveal_at, giver_id, recipient_id, '
      'recipient:profiles!gifts_recipient_id_fkey(id, username, display_name), '
      ' preview:link_previews(id, url, title, image_path, price, site), '
      '$_photosSelect';

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
      return Success([
        for (final r in rows) _entry(r, counterpartKey: 'recipient'),
      ]);
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
      return Success([
        for (final r in rows) _entry(r, counterpartKey: 'giver'),
      ]);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  GiftEntry _entry(Map<String, dynamic> row, {required String counterpartKey}) {
    final counterpart = row[counterpartKey] as Map<String, dynamic>?;
    return GiftEntry(
      id: row['id']! as String,
      item: row['item']! as String,
      note: row['note'] as String?,
      giftDate: DateTime.parse(row['gift_date']! as String),
      isSurprise: row['is_surprise']! as bool,
      revealAt: row['reveal_at'] == null
          ? null
          : DateTime.parse(row['reveal_at']! as String),
      counterpartId: counterpart?['id'] as String?,
      counterpartLabel: counterpart == null
          ? null
          : (counterpart['display_name'] as String?) ??
                (counterpart['username'] as String?),
      preview: row['preview'] == null
          ? null
          : LinkPreview.fromJson(row['preview'] as Map<String, dynamic>),
      giverRelation: row['giver_relation'] == null
          ? null
          : GiftRelation.values.byName(row['giver_relation'] as String),
      photos: _photos(row['photos']),
      giverId: row['giver_id'] as String?,
      recipientId: row['recipient_id'] as String?,
    );
  }

  static List<GiftPhoto> _photos(Object? raw) {
    final rows = (raw as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>();
    final photos = [
      for (final r in rows)
        GiftPhoto(
          id: r['id']! as String,
          giftId: r['gift_id']! as String,
          uploaderId: r['uploader_id']! as String,
          mediaPath: r['media_path']! as String,
          createdAt: DateTime.parse(r['created_at']! as String),
        ),
    ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return photos;
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
          })
          .select(_recipientSelect)
          .single();
      return Success(_entry(row, counterpartKey: 'recipient'));
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
      return Success(_entry(row, counterpartKey: 'giver'));
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
        _entry(row, counterpartKey: counterpartIsGiver ? 'giver' : 'recipient'),
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
      return Success(_photos([row]).single);
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
}
