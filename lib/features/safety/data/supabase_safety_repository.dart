import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:kept/features/safety/domain/safety_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [SafetyRepository]: block/unblock/blocked-list run through
/// SECURITY DEFINER RPCs (atomic block + friendship severing); reports are a
/// plain insert-only table.
class SupabaseSafetyRepository implements SafetyRepository {
  SupabaseSafetyRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<void>> block(String userId) async {
    if (_client.auth.currentUser == null) {
      return const ResultFailure(AuthFailure('Signed out'));
    }
    try {
      await _client.rpc<void>('block_user', params: {'target': userId});
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> unblock(String userId) async {
    try {
      await _client.rpc<void>('unblock_user', params: {'target': userId});
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ProfileCard>>> blockedUsers() async {
    try {
      final rows = await _client.rpc<List<dynamic>>('blocked_users');
      return Success(
        rows
            .map((row) => ProfileCard.fromJson(row as Map<String, dynamic>))
            .toList(),
      );
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> report(
    String userId,
    ReportReason reason, {
    String? details,
  }) async {
    final myId = _client.auth.currentUser?.id;
    if (myId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      await _client.from('reports').insert({
        'reporter_id': myId,
        'reported_id': userId,
        'reason': reason.name,
        if (details != null && details.trim().isNotEmpty)
          'details': details.trim(),
      });
      return const Success(null);
    } on PostgrestException catch (e) {
      // 23505 = the pair is already in the queue — success for the reporter.
      if (e.code == '23505') return const Success(null);
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
