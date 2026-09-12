import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

/// Activity center (G-86, absorbs G-64): incoming friend requests with
/// accept/decline plus upcoming birthdays, in one list. Rows disappear as
/// they're acted on — that's the V1 read state; a persistent notification
/// log arrives with the V2 event feed (G-210).
class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final entries = ref.watch(friendEntriesProvider);
    final upcoming = ref.watch(upcomingBirthdaysProvider);

    ref.listen(friendsControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    final requests =
        entries.valueOrNull
            ?.where(
              (e) =>
                  e.status == FriendshipStatus.pending &&
                  e.direction == RequestDirection.incoming,
            )
            .toList() ??
        const <FriendEntry>[];
    final birthdays = upcoming.valueOrNull ?? const <UpcomingBirthday>[];
    final loading = entries.isLoading || upcoming.isLoading;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityTitle)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(friendEntriesProvider)
            ..invalidate(upcomingBirthdaysProvider);
          await ref.read(friendEntriesProvider.future);
        },
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : (requests.isEmpty && birthdays.isEmpty)
            ? _EmptyState(l10n: l10n)
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  if (requests.isNotEmpty) ...[
                    _SectionLabel(l10n.friendsRequestsSection),
                    for (final e in requests) _RequestRow(entry: e),
                  ],
                  if (birthdays.isNotEmpty) ...[
                    _SectionLabel(l10n.homeUpcomingSection),
                    for (final b in birthdays) _BirthdayRow(birthday: b),
                  ],
                ],
              ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // Scrollable so pull-to-refresh works on the empty state too.
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: constraints.maxHeight,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_none, size: 56),
                const SizedBox(height: 12),
                Text(l10n.activityEmpty),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(text, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class _RequestRow extends ConsumerWidget {
  const _RequestRow({required this.entry});

  final FriendEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(friendsControllerProvider.notifier);
    final busy = ref.watch(friendsControllerProvider).isLoading;

    return ListTile(
      leading: CircleAvatar(
        child: Text(entry.label.substring(0, 1).toUpperCase()),
      ),
      title: Text(entry.label),
      subtitle: Text('@${entry.username}'),
      onTap: () => context.push(
        '/users/${entry.profileId}'
        '?name=${Uri.encodeComponent(entry.label)}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.friendAccept,
            icon: const Icon(Icons.check_circle_outline),
            onPressed: busy
                ? null
                : () => controller.accept(entry.friendshipId),
          ),
          IconButton(
            tooltip: l10n.friendDecline,
            icon: const Icon(Icons.cancel_outlined),
            onPressed: busy
                ? null
                : () => controller.decline(entry.friendshipId),
          ),
        ],
      ),
    );
  }
}

class _BirthdayRow extends StatelessWidget {
  const _BirthdayRow({required this.birthday});

  final UpcomingBirthday birthday;

  String _countdown(BuildContext context) => switch (birthday.daysUntil) {
    0 => context.l10n.homeCountdownToday,
    1 => context.l10n.homeCountdownTomorrow,
    final d => context.l10n.homeCountdownInDays(d),
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.cake_outlined),
      title: Text(birthday.label),
      subtitle: Text(
        context.l10n.homeUsernameCountdown(
          birthday.username,
          _countdown(context),
        ),
      ),
      onTap: () => context.push(
        '/users/${birthday.friendId}'
        '?name=${Uri.encodeComponent(birthday.label)}',
      ),
    );
  }
}
