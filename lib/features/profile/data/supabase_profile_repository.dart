import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_repository.dart';
import 'package:kept/features/profile/domain/username.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [ProfileRepository]. DTO↔domain mapping happens here;
/// nothing above this layer sees PostgREST types.
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'profiles';

  @override
  Future<Result<Profile?>> fetchMyProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', userId)
          .maybeSingle();
      return Success(row == null ? null : Profile.fromJson(row));
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<bool>> isUsernameAvailable(String username) async {
    final error = Username.validate(username);
    if (error != null) {
      return const ResultFailure(ValidationFailure('Invalid username'));
    }
    try {
      final row = await _client
          .from(_table)
          .select('id')
          .ilike('username', Username.normalize(username))
          .maybeSingle();
      return Success(row == null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Profile>> createProfile({
    required String username,
    String? displayName,
    DateTime? birthday,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    final error = Username.validate(username);
    if (error != null) {
      return const ResultFailure(ValidationFailure('Invalid username'));
    }
    try {
      final row = await _client
          .from(_table)
          .insert({
            'id': userId,
            'username': username,
            if (displayName != null) 'display_name': displayName,
            if (birthday != null)
              'birthday': birthday.toIso8601String().substring(0, 10),
          })
          .select()
          .single();
      return Success(Profile.fromJson(row));
    } on PostgrestException catch (e) {
      // 23505 = unique_violation → username raced by another signup.
      if (e.code == '23505') {
        return const ResultFailure(ValidationFailure('Username taken'));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Profile>> updateProfile(Profile profile) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final row = await _client
          .from(_table)
          .update(profile.toJson()..remove('id'))
          .eq('id', userId)
          .select()
          .single();
      return Success(Profile.fromJson(row));
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
