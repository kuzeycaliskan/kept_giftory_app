import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/feed/application/feed_providers.dart';
import 'package:kept/features/feed/presentation/stories_strip.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/gifts/application/gift_reaction_controller.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/gifts/presentation/log_external_gift_screen.dart'
    show giftRelationLabel;
import 'package:kept/features/gifts/presentation/widgets/gift_reaction_row.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/home_feed_items.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/push/application/push_providers.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';
import 'package:kept/shared/widgets/kept_list_group.dart';
import 'package:kept/shared/widgets/kept_section_header.dart';
import 'package:kept/shared/widgets/kept_shimmer.dart';
import 'package:kept/shared/widgets/link_preview_card.dart';
import 'package:kept/shared/widgets/private_media_image.dart';
import 'package:url_launcher/url_launcher.dart';

/// Home dashboard (G-82).
///
/// Friends' live moments (stories strip, G-202) on top, then upcoming
/// birthdays (each row expands into that friend's wishlist); the bell (with
/// a pending-request badge) opens the Activity center (G-86). Feed +
/// dashboard merge fully with G-210.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final upcoming = ref.watch(upcomingBirthdaysProvider);
    final events = ref.watch(homeEventsProvider);
    final teaser = ref.watch(surpriseTeaserProvider).valueOrNull;
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
            ..invalidate(surpriseTeaserProvider)
            ..invalidate(upcomingBirthdaysProvider)
            ..invalidate(homeEventsProvider)
            ..invalidate(friendEntriesProvider);
          await ref.read(upcomingBirthdaysProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            KeptSpacing.lg,
            KeptSpacing.sm,
            KeptSpacing.lg,
            KeptSpacing.lg,
          ),
          children: [
            const StoriesStrip(),
            const SizedBox(height: KeptSpacing.lg),
            const _PushPrimingCard(),
            KeptSectionHeader(l10n.homeUpcomingSection),
            _UpcomingSection(state: upcoming),
            if (hasFriends) ...[
              const SizedBox(height: KeptSpacing.xl),
              KeptSectionHeader(l10n.homeActivitySection),
              if (teaser != null) ...[
                _SurpriseTeaserCard(teaser: teaser),
                const SizedBox(height: KeptSpacing.sm),
              ],
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
        return KeptListGroup(
          children: [for (final b in birthdays) _BirthdayRow(birthday: b)],
        );
      },
    );
  }
}

/// Upcoming-birthday row that expands into the friend's wishlist — the
/// gift idea sits right under the reason to buy one. Avatar → profile,
/// row → toggle, Gift → log form.
class _BirthdayRow extends ConsumerStatefulWidget {
  const _BirthdayRow({required this.birthday});

  final UpcomingBirthday birthday;

  @override
  ConsumerState<_BirthdayRow> createState() => _BirthdayRowState();
}

class _BirthdayRowState extends ConsumerState<_BirthdayRow> {
  bool _expanded = false;

  String _countdown(BuildContext context) =>
      switch (widget.birthday.daysUntil) {
        0 => context.l10n.homeCountdownToday,
        1 => context.l10n.homeCountdownTomorrow,
        final d => context.l10n.homeCountdownInDays(d),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final birthday = widget.birthday;
    final profileRoute =
        '/users/${birthday.friendId}'
        '?name=${Uri.encodeComponent(birthday.label)}';
    return Column(
      children: [
        ListTile(
          leading: GestureDetector(
            onTap: () => context.push(profileRoute),
            child: KeptAvatar(
              label: birthday.label,
              avatarValue: birthday.avatarUrl,
            ),
          ),
          title: Text(
            birthday.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          // Countdown, then the expand affordance inline (accent colour,
          // tiny chevron) — keeps the trailing slot to the one real action.
          subtitle: Row(
            children: [
              Flexible(
                child: Text(
                  _countdown(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(' · ', style: Theme.of(context).textTheme.bodyMedium),
              Text(
                l10n.homeWishlistToggle,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Icons.expand_more,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          onTap: () => setState(() => _expanded = !_expanded),
          trailing: FilledButton.tonal(
            onPressed: () => context.push('/gifts/log'),
            child: Text(l10n.homeGiftCta),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _expanded
              ? _FriendWishes(
                  friendId: birthday.friendId,
                  label: birthday.label,
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// The friend's wishlist inside the expanded row: a few items as cards,
/// then a link to the full list. Loads lazily on first expand; RLS decides
/// what the viewer may see.
class _FriendWishes extends ConsumerWidget {
  const _FriendWishes({required this.friendId, required this.label});

  final String friendId;
  final String label;

  static const int _preview = 4;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final wishes = ref.watch(friendWishlistProvider(friendId));
    return ColoredBox(
      color: scheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KeptSpacing.lg,
          KeptSpacing.sm,
          KeptSpacing.lg,
          KeptSpacing.sm,
        ),
        child: wishes.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(KeptSpacing.md),
            child: Center(
              child: SizedBox.square(
                dimension: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (error, _) => Text(
            l10n.wishlistError,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          data: (items) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: KeptSpacing.sm),
                  child: Text(
                    l10n.homeWishlistEmptyInline,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                for (final item in items.take(_preview)) _WishCard(item: item),
              if (items.length > _preview || items.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(
                      '/users/$friendId/wishlist'
                      '?name=${Uri.encodeComponent(label)}',
                    ),
                    child: Text(l10n.homeWishlistSeeAll),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One wish: the product card when a link preview exists, else a flat row.
class _WishCard extends StatelessWidget {
  const _WishCard({required this.item});

  final WishlistItem item;

  Future<void> _openLink(BuildContext context, String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.legalOpenError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = item.preview;
    if (preview != null) {
      final link = preview.url ?? item.url;
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: KeptSpacing.xs),
        child: LinkPreviewCard(
          preview: preview,
          onTap: link == null ? null : () => _openLink(context, link),
        ),
      );
    }
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: const KeptIconBadge(Icons.star_outline),
      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: item.note == null
          ? null
          : Text(item.note!, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: item.url == null ? null : () => _openLink(context, item.url!),
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
            for (var i = 0; i < events.length; i++) ...[
              if (i > 0) const SizedBox(height: KeptSpacing.sm),
              if (events[i].gift != null)
                _GiftPostCard(event: events[i])
              else
                KeptListGroup(children: [_EventRow(event: events[i])]),
            ],
          ],
        );
      },
    );
  }
}

/// Headline for any event kind, shared by the row and the card.
String _eventTitle(BuildContext context, HomeEvent event) {
  final l10n = context.l10n;
  final actor = event.actorLabel ?? l10n.giftAnonymousGiver;
  return switch (event.kind) {
    HomeEventKind.friendAccepted => l10n.homeEventFriend(actor),
    HomeEventKind.giftReceived => l10n.homeEventGift(actor),
    HomeEventKind.externalGiftLogged => l10n.homeEventExternalGift(
      giftRelationLabel(context, event.giverRelation!),
    ),
    HomeEventKind.friendGiftReceived => l10n.homeEventFriendGift(
      event.recipientLabel ?? l10n.giftAnonymousGiver,
      actor,
    ),
  };
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event});

  final HomeEvent event;

  @override
  Widget build(BuildContext context) {
    final item = event.item;
    return ListTile(
      leading: KeptIconBadge(
        event.kind == HomeEventKind.friendAccepted
            ? Icons.group_add_outlined
            : Icons.card_giftcard_outlined,
      ),
      title: Text(
        _eventTitle(context, event),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      // Gift events without a full payload (older callers) keep the item.
      subtitle: item == null
          ? null
          : Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: event.actorId == null
          ? null
          : () => context.push(
              '/users/${event.actorId}'
              '?name=${Uri.encodeComponent(event.actorLabel ?? '')}',
            ),
    );
  }
}

/// A gift as a post (G-210): who/when, the item, its memory photos and link
/// card. Tap → the gift detail. Rendered flat (outlined card theme).
class _GiftPostCard extends ConsumerWidget {
  const _GiftPostCard({required this.event});

  final HomeEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gift = event.gift!;
    final myId = ref.watch(myProfileProvider).valueOrNull?.id;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.yMMMd(locale).format(gift.giftDate);
    final preview = gift.preview;
    final headLabel = event.kind == HomeEventKind.friendGiftReceived
        ? (event.recipientLabel ?? '')
        : (event.actorLabel ?? '');

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/gifts/${gift.id}?side=giver'),
        child: Padding(
          padding: const EdgeInsets.all(KeptSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (event.kind == HomeEventKind.externalGiftLogged)
                    const KeptIconBadge(Icons.card_giftcard_outlined)
                  else
                    KeptAvatar(label: headLabel.isEmpty ? '?' : headLabel),
                  const SizedBox(width: KeptSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _eventTitle(context, event),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                        Text(
                          date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (gift.photos.isNotEmpty) ...[
                const SizedBox(height: KeptSpacing.md),
                _PhotoRow(photos: gift.photos),
              ],
              const SizedBox(height: KeptSpacing.md),
              Text(
                gift.item,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium,
              ),
              if (preview != null) ...[
                const SizedBox(height: KeptSpacing.sm),
                LinkPreviewCard(preview: preview),
              ],
              const SizedBox(height: KeptSpacing.md),
              GiftReactionRow(
                gift: gift,
                myId: myId,
                onReact: (kind) => ref
                    .read(giftReactionControllerProvider.notifier)
                    .react(gift, kind, myId: myId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Up to three square memory photos, equal width, same rhythm as the
/// detail screen's cards.
class _PhotoRow extends StatelessWidget {
  const _PhotoRow({required this.photos});

  final List<GiftPhoto> photos;

  @override
  Widget build(BuildContext context) {
    final shown = photos.take(giftPhotoCap).toList();
    return Row(
      children: [
        for (var i = 0; i < shown.length; i++) ...[
          if (i > 0) const SizedBox(width: KeptSpacing.sm),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: KeptRadius.controlAll,
                child: PrivateMediaImage(
                  bucket: giftMediaBucket,
                  path: shown[i].mediaPath,
                  fit: BoxFit.cover,
                  compact: true,
                ),
              ),
            ),
          ),
        ],
        // Keep the grid's column width stable with fewer than three photos.
        for (var i = shown.length; i < giftPhotoCap; i++) ...[
          const SizedBox(width: KeptSpacing.sm),
          const Expanded(child: SizedBox.shrink()),
        ],
      ],
    );
  }
}

/// "A surprise is on its way — opens on <date>": the only thing the
/// recipient learns about pending surprises. Soft shimmer = anticipation.
class _SurpriseTeaserCard extends StatelessWidget {
  const _SurpriseTeaserCard({required this.teaser});

  final SurpriseTeaser teaser;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).toString();
    final opens = DateFormat.MMMMd(locale).format(teaser.nextRevealAt);
    return KeptShimmer(
      child: Container(
        padding: const EdgeInsets.all(KeptSpacing.lg),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: KeptRadius.cardAll,
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: scheme.onPrimaryContainer),
            const SizedBox(width: KeptSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.homeSurpriseTeaserTitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    l10n.homeSurpriseTeaserOpens(opens),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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
