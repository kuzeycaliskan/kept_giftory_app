import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:kept/features/feed/presentation/stories_strip.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/home_feed_items.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';
import 'package:kept/features/push/application/push_providers.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';

/// Home dashboard (G-82).
///
/// Friends' live moments (stories strip, G-202) on top, then upcoming
/// birthdays; the bell (with a pending-request badge) opens the Activity
/// center (G-86). Feed + dashboard merge fully with G-210.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final upcoming = ref.watch(upcomingBirthdaysProvider);
    final wishlistFeed = ref.watch(friendWishlistFeedProvider);
    final events = ref.watch(homeEventsProvider);
    final friendEntries = ref.watch(friendEntriesProvider);
    final pendingRequests =
        friendEntries.valueOrNull
            ?.where(
              (e) =>
                  e.status == FriendshipStatus.pending &&
                  e.direction == RequestDirection.incoming,
            )
            .length ??
        0;
    // Cold start: no accepted friends → one focused invite card instead of
    // three empty sections all begging separately (G-36).
    final hasFriends =
        friendEntries.valueOrNull?.any(
          (e) => e.status == FriendshipStatus.accepted,
        ) ??
        true;
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
            tooltip: l10n.friendsTitle,
            icon: const Icon(Icons.person_add_outlined),
            onPressed: () => context.push('/friends'),
          ),
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
            ..invalidate(storyGroupsProvider)
            ..invalidate(upcomingBirthdaysProvider)
            ..invalidate(friendWishlistFeedProvider)
            ..invalidate(homeEventsProvider)
            ..invalidate(friendEntriesProvider);
          await ref.read(upcomingBirthdaysProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const StoriesStrip(),
            const SizedBox(height: 16),
            const _PushPrimingCard(),
            _SectionHeader(title: l10n.homeUpcomingSection),
            const SizedBox(height: 8),
            _UpcomingSection(state: upcoming),
            if (hasFriends) ...[
              const SizedBox(height: 24),
              _SectionHeader(title: l10n.homeWishlistSection),
              const SizedBox(height: 8),
              _WishlistFeedSection(state: wishlistFeed),
              const SizedBox(height: 24),
              _SectionHeader(title: l10n.homeActivitySection),
              const SizedBox(height: 8),
              _EventsSection(state: events),
            ],
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
        leading: KeptAvatar(
          label: birthday.label,
          avatarValue: birthday.avatarUrl,
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

/// Friends' latest wishlist additions — the discovery half of Home (G-82).
class _WishlistFeedSection extends StatelessWidget {
  const _WishlistFeedSection({required this.state});

  final AsyncValue<List<FriendWishlistItem>> state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _InlineError(message: l10n.homeWishlistError),
      data: (items) {
        if (items.isEmpty) {
          return _InviteNudge(message: l10n.homeWishlistEmptyNudge);
        }
        return Column(
          children: [
            for (final item in items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.star_outline),
                title: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '@${item.ownerUsername}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () => context.push(
                  '/users/${item.ownerId}'
                  '?name=${Uri.encodeComponent(item.ownerLabel)}',
                ),
              ),
          ],
        );
      },
    );
  }
}

/// My real social events (new friendships, gifts logged for me). The full
/// social feed arrives with V2 (G-210).
class _EventsSection extends StatelessWidget {
  const _EventsSection({required this.state});

  final AsyncValue<List<HomeEvent>> state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => _InlineError(message: l10n.homeActivityError),
      data: (events) {
        if (events.isEmpty) {
          return _InviteNudge(message: l10n.homeActivityEmptyNudge);
        }
        return Column(
          children: [
            for (final event in events)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(switch (event.kind) {
                  HomeEventKind.friendAccepted => Icons.group_add_outlined,
                  HomeEventKind.giftReceived => Icons.card_giftcard_outlined,
                }),
                title: Text(
                  switch (event.kind) {
                    HomeEventKind.friendAccepted => l10n.homeEventFriend(
                      event.actorLabel ?? l10n.giftAnonymousGiver,
                    ),
                    HomeEventKind.giftReceived => l10n.homeEventGift(
                      event.actorLabel ?? l10n.giftAnonymousGiver,
                    ),
                  },
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: event.actorId == null
                    ? null
                    : () => context.push(
                        '/users/${event.actorId}'
                        '?name=${Uri.encodeComponent(event.actorLabel ?? '')}',
                      ),
              ),
          ],
        );
      },
    );
  }
}

/// Compact growth nudge for an empty section: content here comes from
/// friends, so the fix is inviting more of them (G-36).
class _InviteNudge extends StatelessWidget {
  const _InviteNudge({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.person_add_outlined,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => context.push('/invite'),
              child: Text(context.l10n.homeInviteCta),
            ),
          ],
        ),
      ),
    );
  }
}
