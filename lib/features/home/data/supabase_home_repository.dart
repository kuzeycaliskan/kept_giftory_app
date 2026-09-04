import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/home/domain/birthday_math.dart';
import 'package:kept/features/home/domain/home_repository.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed [HomeRepository].
///
/// Friend ids come from `friendships` (RLS already limits rows to the caller),
/// then friend profiles are read subject to their own visibility policies —
/// a friend whose profile is hidden from us simply drops out of the list.
class SupabaseHomeRepository implements HomeRepository {
  SupabaseHomeRepository(this._client, {DateTime Function()? now})
      : _now = now ?? DateTime.now;

  final SupabaseClient _client;
  final DateTime Function() _now;

  @override
  Future<Result<List<UpcomingBirthday>>> upcomingBirthdays({
    int limit = 10,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final friendRows = await _client
          .from('friendships')
          .select('requester_id, addressee_id')
          .eq('status', 'accepted');

      final friendIds = friendRows
          .map(
            (row) => row['requester_id'] == userId
                ? row['addressee_id']! as String
                : row['requester_id']! as String,
          )
          .toSet()
          .toList();
      if (friendIds.isEmpty) return const Success([]);

      final profileRows = await _client
          .from('profiles')
          .select('id, username, display_name, avatar_url, birthday')
          .inFilter('id', friendIds)
          .not('birthday', 'is', null);

      final today = _now();
      final upcoming = profileRows.map((row) {
        final birthday = DateTime.parse(row['birthday']! as String);
        return UpcomingBirthday(
          friendId: row['id']! as String,
          username: row['username']! as String,
          displayName: row['display_name'] as String?,
          avatarUrl: row['avatar_url'] as String?,
          birthday: birthday,
          daysUntil: daysUntilBirthday(birthday, today),
        );
      }).toList()
        ..sort((a, b) => a.daysUntil.compareTo(b.daysUntil));

      return Success(upcoming.take(limit).toList());
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}
