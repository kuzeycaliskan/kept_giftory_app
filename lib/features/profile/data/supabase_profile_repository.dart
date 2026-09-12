import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/profile/domain/profile_card.dart';
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

  @override
  Future<Result<Profile>> setBirthdayReminders({required bool enabled}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final row = await _client
          .from(_table)
          .update({'birthday_reminders_enabled': enabled})
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

  @override
  Future<Result<List<ProfileCard>>> searchProfiles(String query) async {
    if (_client.auth.currentUser == null) {
      return const ResultFailure(AuthFailure('Signed out'));
    }
    if (query.trim().isEmpty) return const Success([]);
    // Escaping, min length, self-exclusion and the 20-row cap live in the
    // SECURITY DEFINER function — the single discovery surface (G-32).
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'search_profiles',
        params: {'q': query.trim()},
      );
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
  Future<Result<ProfileCard?>> fetchProfileCard(String profileId) async {
    if (_client.auth.currentUser == null) {
      return const ResultFailure(AuthFailure('Signed out'));
    }
    try {
      final rows = await _client.rpc<List<dynamic>>(
        'profile_card',
        params: {'target': profileId},
      );
      if (rows.isEmpty) return const Success(null);
      return Success(ProfileCard.fromJson(rows.first as Map<String, dynamic>));
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
      // Only the G-23 editable columns. Username is deliberately absent —
      // it's identity, locked in V1 (changes go through support). Visibility,
      // invite code and avatar have their own dedicated paths. Explicit
      // nulls clear optional fields.
      final row = await _client
          .from(_table)
          .update({
            'display_name': profile.displayName,
            'birthday': profile.birthday?.toIso8601String().substring(0, 10),
            'occupation': profile.occupation,
            'bio': profile.bio,
          })
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
