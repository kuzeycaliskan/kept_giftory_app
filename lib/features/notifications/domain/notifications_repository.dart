import 'package:kept/core/error/result.dart';
import 'package:kept/features/notifications/domain/app_notification.dart';

abstract interface class NotificationsRepository {
  /// Newest first; RLS scopes to the signed-in user.
  Future<Result<List<AppNotification>>> fetchRecent({int limit = 50});

  Future<Result<void>> markRead(String id);

  Future<Result<void>> markAllRead();
}
