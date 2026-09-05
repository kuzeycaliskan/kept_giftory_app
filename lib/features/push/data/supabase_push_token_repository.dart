import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/push/domain/push_token_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [PushTokenRepository]. Token is the PK: re-registering
/// moves it between users (device changed accounts).
class SupabasePushTokenRepository implements PushTokenRepository {
  SupabasePushTokenRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Result<void>> register({
    required String token,
    required String platform,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      await _client.from('device_tokens').upsert({
        'token': token,
        'user_id': userId,
        'platform': platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> unregister(String token) async {
    try {
      await _client.from('device_tokens').delete().eq('token', token);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}

/// Backend-less / dev-session fallback.
class NoopPushTokenRepository implements PushTokenRepository {
  const NoopPushTokenRepository();

  @override
  Future<Result<void>> register({
    required String token,
    required String platform,
  }) async =>
      const Success(null);

  @override
  Future<Result<void>> unregister(String token) async => const Success(null);
}
