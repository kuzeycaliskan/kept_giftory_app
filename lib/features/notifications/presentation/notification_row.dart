import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/router/follow_route.dart';
import 'package:kept/features/notifications/application/notifications_providers.dart';
import 'package:kept/features/notifications/domain/app_notification.dart';
import 'package:kept/shared/widgets/kept_list_group.dart';

/// One inbox row: unread rows carry a dot; a tap marks it read and follows
/// its route when it has one.
class NotificationRow extends ConsumerWidget {
  const NotificationRow({required this.notification, super.key});

  final AppNotification notification;

  static IconData iconFor(String kind) {
    if (kind.startsWith('pool')) return Icons.group_outlined;
    if (kind.startsWith('event')) return Icons.celebration_outlined;
    if (kind.startsWith('comment')) return Icons.chat_bubble_outline;
    return Icons.redeem_outlined;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final unread = notification.isUnread;
    final when = DateFormat.MMMd(
      locale,
    ).add_Hm().format(notification.createdAt);
    return ListTile(
      leading: KeptIconBadge(iconFor(notification.kind)),
      title: Text(
        notification.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: unread
            ? theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)
            : null,
      ),
      subtitle: Text(
        '${notification.body}\n$when',
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
      isThreeLine: true,
      trailing: unread
          ? Icon(Icons.circle, size: 10, color: theme.colorScheme.primary)
          : null,
      onTap: () {
        if (unread) {
          unawaited(
            ref
                .read(notificationsControllerProvider.notifier)
                .markRead(notification.id),
          );
        }
        final route = notification.route;
        if (route != null) followRoute(GoRouter.of(context), route);
      },
    );
  }
}
