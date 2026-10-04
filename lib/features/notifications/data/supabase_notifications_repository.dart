import 'package:kept/core/error/failure.dart';
import 'package:kept/core/error/result.dart';
import 'package:kept/features/notifications/domain/app_notification.dart';
import 'package:kept/features/notifications/domain/notifications_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client);

  final SupabaseClient _client;

  static const _table = 'notifications';

  @override
  Future<Result<List<AppNotification>>> fetchRecent({int limit = 50}) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return const ResultFailure(AuthFailure('Signed out'));
    try {
      final rows = await _client
          .from(_table)
          .select('id, kind, title, body, route, created_at, read_at')
          .order('created_at', ascending: false)
          .limit(limit);
      return Success([
        for (final r in rows)
          AppNotification(
            id: r['id']! as String,
            kind: r['kind']! as String,
            title: r['title']! as String,
            body: r['body']! as String,
            route: r['route'] as String?,
            createdAt: DateTime.parse(r['created_at']! as String).toLocal(),
            readAt: switch (r['read_at']) {
              final String s => DateTime.parse(s).toLocal(),
              _ => null,
            },
          ),
      ]);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> markRead(String id) => _run(
    () => _client
        .from(_table)
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id)
        .isFilter('read_at', null),
  );

  @override
  Future<Result<void>> markAllRead() => _run(
    () => _client
        .from(_table)
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .isFilter('read_at', null),
  );

  Future<Result<void>> _run(Future<void> Function() action) async {
    try {
      await action();
      return const Success(null);
    } on PostgrestException catch (e) {
      return ResultFailure(NetworkFailure(e.message));
    } catch (e) {
      return ResultFailure(UnknownFailure(e.toString()));
    }
  }
}

/// Backend-less runs: an empty inbox.
class EmptyNotificationsRepository implements NotificationsRepository {
  const EmptyNotificationsRepository();

  @override
  Future<Result<List<AppNotification>>> fetchRecent({int limit = 50}) async =>
      const Success([]);

  @override
  Future<Result<void>> markRead(String id) async => const Success(null);

  @override
  Future<Result<void>> markAllRead() async => const Success(null);
}
