import 'package:flutter/foundation.dart';

/// One row of the in-app inbox (`public.notifications`): the server writes
/// a copy of every push it sends, so the bell shows it whether or not the
/// device took the push.
@immutable
class AppNotification {
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.route,
    this.readAt,
  });

  final String id;
  final String kind;
  final String title;
  final String body;
  final String? route;
  final DateTime createdAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;
}
