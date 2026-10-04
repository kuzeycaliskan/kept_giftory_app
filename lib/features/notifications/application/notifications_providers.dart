import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/env/env.dart';
import 'package:kept/core/supabase/supabase_providers.dart';
import 'package:kept/features/notifications/data/supabase_notifications_repository.dart';
import 'package:kept/features/notifications/domain/app_notification.dart';
import 'package:kept/features/notifications/domain/notifications_repository.dart';

// Hand-written providers: the riverpod code generator does not run on the
// current Flutter SDK (see session notes); these mirror what it would emit.

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  if (!Env.hasSupabaseConfig) return const EmptyNotificationsRepository();
  return SupabaseNotificationsRepository(ref.watch(supabaseClientProvider));
});

/// The inbox, newest first.
final notificationsProvider = FutureProvider.autoDispose<List<AppNotification>>(
  (ref) async {
    final result = await ref
        .watch(notificationsRepositoryProvider)
        .fetchRecent();
    return result.when(success: (l) => l, failure: (f) => throw f);
  },
);

/// What the bell counts, besides friend requests and event invitations.
final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  return ref
          .watch(notificationsProvider)
          .valueOrNull
          ?.where((n) => n.isUnread)
          .length ??
      0;
});

class NotificationsController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> markRead(String id) async {
    final result = await ref.read(notificationsRepositoryProvider).markRead(id);
    result.when(
      success: (_) => ref.invalidate(notificationsProvider),
      failure: (f) => state = AsyncError(f, StackTrace.current),
    );
  }

  Future<void> markAllRead() async {
    state = const AsyncLoading();
    final result = await ref
        .read(notificationsRepositoryProvider)
        .markAllRead();
    result.when(
      success: (_) {
        state = const AsyncData(null);
        ref.invalidate(notificationsProvider);
      },
      failure: (f) => state = AsyncError(f, StackTrace.current),
    );
  }
}

final notificationsControllerProvider =
    NotifierProvider<NotificationsController, AsyncValue<void>>(
      NotificationsController.new,
    );
