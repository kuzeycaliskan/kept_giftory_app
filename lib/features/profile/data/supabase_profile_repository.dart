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
    return fetchProfile(userId);
  }

  @override
  Future<Result<Profile?>> fetchProfile(String profileId) async {
    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', profileId)
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
      // 23503 = FK violation on auth.users: the device holds a JWT for a
      // user deleted server-side (ghost session) — force re-authentication.
      if (e.code == '23503') {
        return const ResultFailure(AuthFailure('Session user deleted'));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Profile>> updateVisibility({
    Visibility? profile,
    Visibility? wishlist,
    Visibility? giftHistory,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    // Enum names match the Postgres enum labels — see profile.dart.
    final patch = {
      if (profile != null) 'profile_visibility': profile.name,
      if (wishlist != null) 'wishlist_visibility': wishlist.name,
      if (giftHistory != null) 'gift_history_visibility': giftHistory.name,
    };
    if (patch.isEmpty) {
      return const ResultFailure(ValidationFailure('Nothing to update'));
    }
    try {
      final row = await _client
          .from(_table)
          .update(patch)
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

  /// Max results per search — plenty for a type-ahead list, keeps the query
  /// bounded (CLAUDE.md §10: never load unbounded collections).
  static const _searchLimit = 20;

  @override
  Future<Result<List<Profile>>> searchProfiles(String query) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Success([]);
    // Escape ilike wildcards (literal search) and strip characters that
    // would break PostgREST's or() filter syntax.
    final escaped = trimmed
        .replaceAll(RegExp('[,()]'), '')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    if (escaped.isEmpty) return const Success([]);
    try {
      final rows = await _client
          .from(_table)
          .select()
          .neq('id', userId)
          .or('username.ilike.%$escaped%,display_name.ilike.%$escaped%')
          .order('username', ascending: true)
          .limit(_searchLimit);
      return Success(rows.map(Profile.fromJson).toList());
    } on PostgrestException catch (e) {
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
