import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';
import 'package:kept/features/push/application/push_providers.dart';

/// Home dashboard (G-82).
///
/// Shows friends' upcoming birthdays; the bell (with a pending-request
/// badge) opens the Activity center (G-86). A social activity feed arrives
/// with V2 (G-210).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final upcoming = ref.watch(upcomingBirthdaysProvider);
    final pendingRequests =
        ref
            .watch(friendEntriesProvider)
            .valueOrNull
            ?.where(
              (e) =>
                  e.status == FriendshipStatus.pending &&
                  e.direction == RequestDirection.incoming,
            )
            .length ??
        0;
    // Fire-and-forget: refresh the stored FCM token when permission exists.
    ref.watch(pushTokenSyncProvider);

    return Scaffold(
      appBar: AppBar(
        // Brand mark + wordmark: a new brand teaches its symbol by pairing
        // it with the name (mark is decorative; the text carries semantics).
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/branding/icon_mark.png',
              width: 28,
              height: 28,
              excludeFromSemantics: true,
            ),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: pendingRequests > 0,
              label: Text('$pendingRequests'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: l10n.activityTooltip,
            onPressed: () => context.push('/activity'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(upcomingBirthdaysProvider)
            ..invalidate(friendEntriesProvider);
          await ref.read(upcomingBirthdaysProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const _PushPrimingCard(),
            _SectionHeader(title: l10n.homeUpcomingSection),
            const SizedBox(height: 8),
            _UpcomingSection(state: upcoming),
          ],
        ),
      ),
    );
  }
}

/// Soft-ask before the OS notification prompt (G-61): explains the value
/// (birthday reminders) and only then triggers the system dialog. Hidden
/// once granted or dismissed; re-enabling lives in settings (G-63/G-85).
class _PushPrimingCard extends ConsumerWidget {
  const _PushPrimingCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final show = ref.watch(shouldShowPushPrimingProvider);
    if (show.valueOrNull != true) return const SizedBox.shrink();

    final setup = ref.read(pushSetupProvider.notifier);
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active_outlined),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.pushPrimingTitle,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pushPrimingBody,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: setup.dismiss,
                  child: Text(l10n.pushPrimingLater),
                ),
                const SizedBox(width: 8),
                FilledButton.tonal(
                  onPressed: setup.enable,
                  child: Text(l10n.pushPrimingEnable),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({required this.state});

  final AsyncValue<List<UpcomingBirthday>> state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _InlineError(message: l10n.homeUpcomingError),
      data: (birthdays) {
        if (birthdays.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.cake_outlined, size: 40),
                  const SizedBox(height: 8),
                  Text(l10n.homeNoUpcoming),
                  const SizedBox(height: 4),
                  Text(
                    l10n.homeNoUpcomingHint,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => context.push('/friends'),
                    child: Text(l10n.homeFindFriends),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [for (final b in birthdays) _BirthdayCard(birthday: b)],
        );
      },
    );
  }
}

class _BirthdayCard extends StatelessWidget {
  const _BirthdayCard({required this.birthday});

  final UpcomingBirthday birthday;

  String _countdown(BuildContext context) => switch (birthday.daysUntil) {
    0 => context.l10n.homeCountdownToday,
    1 => context.l10n.homeCountdownTomorrow,
    final d => context.l10n.homeCountdownInDays(d),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(birthday.label.substring(0, 1).toUpperCase()),
        ),
        title: Text(birthday.label),
        subtitle: Text(
          l10n.homeUsernameCountdown(birthday.username, _countdown(context)),
        ),
        // Tap → the friend's profile (wishlist + history in its tabs).
        onTap: () => context.push(
          '/users/${birthday.friendId}'
          '?name=${Uri.encodeComponent(birthday.label)}',
        ),
        trailing: FilledButton.tonal(
          onPressed: () => context.push('/gifts/log'),
          child: Text(l10n.homeGiftCta),
        ),
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
