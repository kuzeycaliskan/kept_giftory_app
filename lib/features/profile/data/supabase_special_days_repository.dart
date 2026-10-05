import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/events/domain/event_kind.dart';
import 'package:kept/features/profile/domain/special_day.dart';
import 'package:kept/features/profile/domain/special_days_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseSpecialDaysRepository implements SpecialDaysRepository {
  SupabaseSpecialDaysRepository(this._client);

  final SupabaseClient _client;

  static const _columns = 'id, user_id, kind, title, day';

  @override
  Future<Result<List<SpecialDay>>> fetchMine() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final rows = await _client
          .from('special_days')
          .select(_columns)
          .eq('user_id', userId)
          .gte('day', _isoDate(DateTime.now()))
          .order('day', ascending: true);
      return Success(rows.map(specialDayFromRow).toList());
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<SpecialDay>> add({
    required EventKind kind,
    required DateTime day,
    String? title,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final row = await _client
          .from('special_days')
          .insert({
            'user_id': userId,
            'kind': kind.wire,
            'day': _isoDate(day),
            'title': ?title,
          })
          .select(_columns)
          .single();
      return Success(specialDayFromRow(row));
    } on PostgrestException catch (e) {
      if (e.code == '23514' || e.code == '23505') {
        return ResultFailure(ValidationFailure(e.message));
      }
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> remove(String id) async {
    try {
      await _client.from('special_days').delete().eq('id', id);
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}

SpecialDay specialDayFromRow(Map<String, dynamic> row) => SpecialDay(
  id: row['id']! as String,
  userId: row['user_id']! as String,
  kind: EventKind.fromWire(row['kind']! as String),
  title: row['title'] as String?,
  day: DateTime.parse(row['day']! as String),
);

String _isoDate(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
