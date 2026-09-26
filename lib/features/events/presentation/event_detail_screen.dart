import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/events/application/event_comment_target.dart';
import 'package:kept/features/events/application/events_providers.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/features/gifts/presentation/widgets/gift_list_tile.dart';
import 'package:kept/features/home/domain/birthday_math.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/wishlist/application/claims_providers.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/presentation/claimable_wishlist.dart';
import 'package:kept/shared/widgets/comments_sheet.dart';
import 'package:kept/shared/widgets/kept_action_sheet.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';
import 'package:kept/shared/widgets/kept_list_group.dart';
import 'package:kept/shared/widgets/kept_section_header.dart';
import 'package:url_launcher/url_launcher.dart';

/// One gift event (V3.0-a): who it's for and when, the group link, the
/// people in it, inviting more. Reservations/pooling (V3.0-b) and the notes
/// board (V3.0-d) attach here later.
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final event = ref.watch(eventDetailProvider(eventId));
    final myId = ref.watch(myProfileProvider).valueOrNull?.id;
    final busy = ref.watch(eventsControllerProvider).isLoading;

    ref.listen(eventsControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventsDetailTitle),
        actions: [
          if (event.valueOrNull case final e? when e.me(myId) != null)
            IconButton(
              tooltip: l10n.storyMoreActions,
              icon: const Icon(Icons.more_horiz),
              onPressed: busy ? null : () => _actions(context, ref, e, myId),
            ),
        ],
      ),
      body: event.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.eventsError)),
        data: (e) {
          if (e == null) return Center(child: Text(l10n.eventsMissing));
          // Pull refreshes everything on the page: the event (members,
          // notes count) and the honoree's ideas with their claims.
          return RefreshIndicator(
            onRefresh: () async {
              ref
                ..invalidate(eventDetailProvider(eventId))
                ..invalidate(eventGiftsProvider(eventId))
                ..invalidate(friendWishlistProvider(e.honoreeId))
                ..invalidate(wishlistClaimsProvider(e.honoreeId));
              await ref.read(eventDetailProvider(eventId).future);
            },
            // The honoree only ever gets here once the event is revealed
            // (RLS) — a different page: who was in, the gifts, the thanks.
            child: e.isHonoree(myId)
                ? _HonoreeBody(event: e, busy: busy)
                : _Body(event: e, myId: myId, busy: busy),
          );
        },
      ),
    );
  }

  Future<void> _actions(
    BuildContext context,
    WidgetRef ref,
    GiftEvent event,
    String? myId,
  ) async {
    final l10n = context.l10n;
    final controller = ref.read(eventsControllerProvider.notifier);
    final organizer = event.isOrganizer(myId);
    final label = event.honoreeLabel(l10n.giftAnonymousGiver);
    await showKeptActionSheet(
      context,
      actions: [
        if (organizer && event.isOpen)
          KeptSheetAction(
            icon: Icons.celebration_outlined,
            label: l10n.eventsRevealNow,
            onTap: () => _confirm(
              context,
              title: l10n.eventsRevealConfirmTitle,
              body: l10n.eventsRevealConfirmBody(label),
              action: l10n.eventsRevealNow,
              onConfirm: () => controller.reveal(event.id),
              popAfter: false,
            ),
          ),
        if (organizer)
          KeptSheetAction(
            icon: Icons.link,
            label: l10n.eventsSetChatLink,
            onTap: () => _editChatLink(context, ref, event),
          ),
        if (organizer)
          KeptSheetAction(
            icon: Icons.cancel_outlined,
            label: l10n.eventsCancel,
            destructive: true,
            onTap: () => _confirm(
              context,
              title: l10n.eventsCancelConfirmTitle,
              body: l10n.eventsCancelConfirmBody,
              action: l10n.eventsCancel,
              onConfirm: () => controller.cancel(event.id),
              popAfter: true,
            ),
          )
        else
          KeptSheetAction(
            icon: Icons.logout,
            label: l10n.eventsLeave,
            destructive: true,
            onTap: () => _confirm(
              context,
              title: l10n.eventsLeaveConfirmTitle,
              body: l10n.eventsLeaveConfirmBody,
              action: l10n.eventsLeave,
              onConfirm: () => controller.leave(event.id),
              popAfter: true,
            ),
          ),
      ],
    );
  }

  Future<void> _confirm(
    BuildContext context, {
    required String title,
    required String body,
    required String action,
    required Future<bool> Function() onConfirm,
    required bool popAfter,
  }) async {
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(action),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    final ok = await onConfirm();
    if (ok && popAfter && navigator.canPop()) navigator.pop();
  }

  Future<void> _editChatLink(
    BuildContext context,
    WidgetRef ref,
    GiftEvent event,
  ) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: event.externalChatUrl);
    final url = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.eventsSetChatLink),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(hintText: l10n.eventsChatLinkHint),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    controller.dispose();
    if (url == null) return;
    await ref
        .read(eventsControllerProvider.notifier)
        .setChatUrl(event.id, url.isEmpty ? null : url);
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.event, required this.myId, required this.busy});

  final GiftEvent event;
  final String? myId;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final label = event.honoreeLabel(l10n.giftAnonymousGiver);
    final date = DateFormat.yMMMMd(locale).format(event.eventDate);
    final days = daysUntilBirthday(event.eventDate, DateTime.now());
    final controller = ref.read(eventsControllerProvider.notifier);
    final chat = event.externalChatUrl;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(KeptSpacing.lg),
      children: [
        Row(
          children: [
            KeptAvatar(
              label: label,
              avatarValue: event.honoree?.avatarUrl,
              radius: 28,
            ),
            const SizedBox(width: KeptSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.eventsRowTitle(label),
                    style: theme.textTheme.titleLarge,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    days == 0
                        ? l10n.homeCountdownToday
                        : '$date · ${l10n.homeCountdownInDays(days)}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: KeptSpacing.md),
        // The honoree never sees this screen (RLS) — say so once, plainly.
        Text(
          l10n.eventsSecretNote(label),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (event.isRevealed) ...[
          const SizedBox(height: KeptSpacing.md),
          _RevealedBanner(event: event),
        ],
        if (event.isInvited(myId)) ...[
          const SizedBox(height: KeptSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => controller.respond(event.id, join: false),
                  child: Text(l10n.eventsDecline),
                ),
              ),
              const SizedBox(width: KeptSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: busy
                      ? null
                      : () => controller.respond(event.id, join: true),
                  child: Text(l10n.eventsJoin),
                ),
              ),
            ],
          ),
        ],
        if (chat != null) ...[
          const SizedBox(height: KeptSpacing.lg),
          FilledButton.tonalIcon(
            onPressed: () => launchUrl(
              Uri.parse(chat),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.chat_outlined),
            label: Text(l10n.eventsOpenChat),
          ),
        ],
        if (event.me(myId)?.status == EventMemberStatus.joined) ...[
          const SizedBox(height: KeptSpacing.xl),
          KeptSectionHeader(l10n.eventsGiftsSection),
          _EventGifts(eventId: event.id),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: busy
                  ? null
                  : () => context.push(
                      '/gifts/log?recipient=${event.honoreeId}'
                      '&event=${event.id}',
                    ),
              icon: const Icon(Icons.add),
              label: Text(l10n.eventsLogGift),
            ),
          ),
          // The honoree's wishlist with "I'll get this" / group-gift strips:
          // the coordination core (G-303/G-304). Members only — an invitee
          // hasn't committed to keeping the secret yet.
          const SizedBox(height: KeptSpacing.xl),
          KeptSectionHeader(l10n.claimsIdeasSection),
          ClaimableWishlist(
            ownerId: event.honoreeId,
            ownerLabel: label,
            eventId: event.id,
          ),
          const SizedBox(height: KeptSpacing.xl),
          KeptSectionHeader(l10n.eventsBoardSection),
          CommentPill(
            count: event.commentCount,
            onTap: () => showCommentsSheet(
              context,
              target: EventCommentTarget(
                ref.read(eventsRepositoryProvider),
                event,
                onChanged: () => ref
                  ..invalidate(eventDetailProvider)
                  ..invalidate(myEventsProvider),
              ),
              viewerId: myId,
            ),
          ),
        ],
        const SizedBox(height: KeptSpacing.xl),
        KeptSectionHeader(l10n.eventsMembersSection(event.joined.length)),
        KeptListGroup(
          children: [
            for (final m in event.joined) _MemberRow(member: m, myId: myId),
            for (final m in event.invited)
              _MemberRow(member: m, myId: myId, pending: true),
            if (event.isOpen &&
                event.me(myId)?.status == EventMemberStatus.joined)
              ListTile(
                leading: const KeptIconBadge(Icons.person_add_outlined),
                title: Text(l10n.eventsInviteMore),
                onTap: busy ? null : () => _showInvite(context, ref, event),
              ),
          ],
        ),
      ],
    );
  }

  Future<void> _showInvite(
    BuildContext context,
    WidgetRef ref,
    GiftEvent event,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _InviteSheet(eventId: event.id),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.myId,
    this.pending = false,
  });

  final EventMember member;
  final String? myId;
  final bool pending;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = member.labelOr(l10n.giftAnonymousGiver);
    return ListTile(
      leading: KeptAvatar(label: label, avatarValue: member.user?.avatarUrl),
      title: Text(
        member.userId == myId ? l10n.storiesYou : label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: pending
          ? Text(l10n.eventsMemberInvited)
          : member.role == EventMemberRole.organizer
          ? Text(l10n.eventsOrganizerBadge)
          : null,
    );
  }
}

class _InviteSheet extends ConsumerWidget {
  const _InviteSheet({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final candidates = ref.watch(invitableFriendsProvider(eventId));
    final busy = ref.watch(eventsControllerProvider).isLoading;
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.6,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KeptSpacing.lg,
              0,
              KeptSpacing.lg,
              KeptSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.eventsInviteMore,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            child: candidates.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.eventsError)),
              data: (people) {
                if (people.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(KeptSpacing.xl),
                      child: Text(
                        l10n.eventsInviteNobody,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView(
                  children: [
                    for (final p in people)
                      ListTile(
                        leading: KeptAvatar(
                          label: p.displayName ?? p.username,
                          avatarValue: p.avatarUrl,
                        ),
                        title: Text(
                          p.displayName ?? p.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text('@${p.username}'),
                        trailing: FilledButton.tonal(
                          onPressed: busy
                              ? null
                              : () => ref
                                    .read(eventsControllerProvider.notifier)
                                    .invite(eventId, p.id),
                          child: Text(l10n.eventsInvite),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Members' view of a revealed event: when it opened, and the honoree's
/// thank-you once it arrived.
class _RevealedBanner extends StatelessWidget {
  const _RevealedBanner({required this.event});

  final GiftEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final revealed = event.revealedAt;
    final note = event.thanksNote;
    final label = event.honoreeLabel(l10n.giftAnonymousGiver);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.celebration_outlined, color: theme.colorScheme.primary),
            const SizedBox(width: KeptSpacing.sm),
            Expanded(
              child: Text(
                revealed == null
                    ? l10n.eventsRevealNow
                    : l10n.eventsRevealedOn(
                        DateFormat.yMMMMd(locale).format(revealed.toLocal()),
                      ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        if (note != null) ...[
          const SizedBox(height: KeptSpacing.md),
          _ThanksCard(name: label, note: note),
        ],
      ],
    );
  }
}

class _ThanksCard extends StatelessWidget {
  const _ThanksCard({required this.name, required this.note});

  final String name;
  final String note;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(KeptSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: KeptRadius.cardAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.eventsThanksFrom(name),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: KeptSpacing.xs),
          Text(
            note,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gifts logged against the event — members see them as they log, the
/// honoree once revealed (RLS opens linked surprises with the event).
class _EventGifts extends ConsumerWidget {
  const _EventGifts({required this.eventId});

  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final gifts = ref.watch(eventGiftsProvider(eventId));
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return gifts.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(KeptSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: KeptSpacing.sm),
        child: Text(l10n.giftsError, style: muted),
      ),
      data: (list) => list.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: KeptSpacing.sm),
              child: Text(l10n.eventsGiftsEmpty, style: muted),
            )
          : KeptListGroup(
              children: [
                for (final gift in list)
                  GiftListTile(
                    gift: gift,
                    directionIcon: Icons.redeem_outlined,
                    counterpartIsGiver: true,
                  ),
              ],
            ),
    );
  }
}

/// The honoree's page (G-307): who came together, what they logged, and
/// one thank-you back. No board, no reservations — those stay backstage.
class _HonoreeBody extends StatefulWidget {
  const _HonoreeBody({required this.event, required this.busy});

  final GiftEvent event;
  final bool busy;

  @override
  State<_HonoreeBody> createState() => _HonoreeBodyState();
}

class _HonoreeBodyState extends State<_HonoreeBody> {
  bool _editing = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final event = widget.event;
    final revealed = event.revealedAt;
    final note = event.thanksNote;
    // Tapping anywhere outside the composer (or dragging the list) puts
    // the keyboard away.
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(KeptSpacing.lg),
        children: [
          Row(
            children: [
              const KeptIconBadge(Icons.celebration_outlined),
              const SizedBox(width: KeptSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.eventsHonoreeTitle,
                      style: theme.textTheme.titleLarge,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (revealed != null)
                      Text(
                        l10n.eventsRevealedOn(
                          DateFormat.yMMMMd(locale).format(revealed.toLocal()),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KeptSpacing.xl),
          KeptSectionHeader(l10n.eventsMembersSection(event.joined.length)),
          KeptListGroup(
            children: [
              for (final m in event.joined) _MemberRow(member: m, myId: null),
            ],
          ),
          const SizedBox(height: KeptSpacing.xl),
          KeptSectionHeader(l10n.eventsGiftsSection),
          _EventGifts(eventId: event.id),
          const SizedBox(height: KeptSpacing.xl),
          KeptSectionHeader(l10n.eventsThanksTitle),
          if (note != null && !_editing) ...[
            _ThanksCard(name: l10n.storiesYou, note: note),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () => setState(() => _editing = true),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(l10n.eventsThanksEdit),
              ),
            ),
          ] else
            _ThanksComposer(
              eventId: event.id,
              busy: widget.busy,
              initialText: note,
              onSent: () => setState(() => _editing = false),
            ),
        ],
      ),
    );
  }
}

class _ThanksComposer extends ConsumerStatefulWidget {
  const _ThanksComposer({
    required this.eventId,
    required this.busy,
    this.initialText,
    this.onSent,
  });

  final String eventId;
  final bool busy;

  /// Editing an existing note starts from it.
  final String? initialText;
  final VoidCallback? onSent;

  @override
  ConsumerState<_ThanksComposer> createState() => _ThanksComposerState();
}

class _ThanksComposerState extends ConsumerState<_ThanksComposer> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final note = _controller.text.trim();
    if (note.isEmpty) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await ref
        .read(eventsControllerProvider.notifier)
        .thank(widget.eventId, note);
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    messenger.showSnackBar(
      SnackBar(content: Text(ok ? l10n.eventsThanksSent : l10n.errorGeneric)),
    );
    if (ok) widget.onSent?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          maxLength: 500,
          maxLines: 4,
          minLines: 2,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(hintText: l10n.eventsThanksHint),
        ),
        const SizedBox(height: KeptSpacing.sm),
        FilledButton.icon(
          onPressed: widget.busy ? null : _send,
          icon: const Icon(Icons.send_outlined),
          label: Text(l10n.eventsThanksSend),
        ),
      ],
    );
  }
}
