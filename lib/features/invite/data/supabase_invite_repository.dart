import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/invite/domain/invite_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [InviteRepository]; redemption goes through the
/// SECURITY DEFINER `redeem_invite` RPC.
class SupabaseInviteRepository implements InviteRepository {
  SupabaseInviteRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<String>> fetchMyCode() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final row = await _client
          .from('profiles')
          .select('invite_code')
          .eq('id', userId)
          .single();
      return Success(row['invite_code']! as String);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<RedeemedInvite>> redeem(String code) async {
    try {
      final rows = await _client
          .rpc<List<dynamic>>('redeem_invite', params: {'code': code.trim()});
      final row = rows.first as Map<String, dynamic>;
      return Success(
        RedeemedInvite(
          inviterId: row['inviter_id']! as String,
          label: (row['display_name'] as String?) ??
              (row['username']! as String),
        ),
      );
    } on PostgrestException catch (e) {
      // P0001 = raised in redeem_invite: invite_not_found / invite_self.
      if (e.code == 'P0001') {
        return ResultFailure(ValidationFailure(e.message));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
