import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/domain/gift_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [GiftRepository]. Counterpart profiles come via embedded
/// selects; a null giver embed = anonymized (deleted) giver.
class SupabaseGiftRepository implements GiftRepository {
  SupabaseGiftRepository(this._client);

  final SupabaseClient _client;

  static const _giverSelect = 'id, item, note, gift_date, is_surprise, '
      'reveal_at, giver_id, '
      'giver:profiles!gifts_giver_id_fkey(id, username, display_name)';
  static const _recipientSelect = 'id, item, note, gift_date, is_surprise, '
      'reveal_at, recipient_id, '
      'recipient:profiles!gifts_recipient_id_fkey(id, username, display_name)';

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
        [for (final r in rows) _entry(r, counterpartKey: 'recipient')],
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
        [for (final r in rows) _entry(r, counterpartKey: 'giver')],
      );
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  GiftEntry _entry(
    Map<String, dynamic> row, {
    required String counterpartKey,
  }) {
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
    );
  }

  @override
  Future<Result<GiftEntry>> log({
    required String recipientId,
    required String item,
    required DateTime giftDate,
    required bool isSurprise,
    String? note,
    DateTime? revealAt,
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
}
