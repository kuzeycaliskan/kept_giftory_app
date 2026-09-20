import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/events/application/events_providers.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/home/domain/birthday_math.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';
import 'package:kept/shared/widgets/kept_list_group.dart';
import 'package:kept/shared/widgets/kept_section_header.dart';

/// Events hub (V3.0-a): pending invitations first, then the events I'm in.
/// Lives as the third segment of the Gifts tab.
class EventsPage extends ConsumerWidget {
  const EventsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final events = ref.watch(myEventsProvider);
    final myId = ref.watch(myProfileProvider).valueOrNull?.id;
    return events.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.eventsError)),
      data: (list) {
        final invites = list.where((e) => e.isInvited(myId)).toList();
        final mine = list.where((e) => !e.isInvited(myId)).toList();
        if (list.isEmpty) return const _EmptyState();
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(myEventsProvider);
            await ref.read(myEventsProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              KeptSpacing.lg,
              KeptSpacing.sm,
              KeptSpacing.lg,
              88,
            ),
            children: [
              if (invites.isNotEmpty) ...[
                KeptSectionHeader(l10n.eventsInvitesSection),
                KeptListGroup(
                  children: [for (final e in invites) _InviteRow(event: e)],
                ),
                const SizedBox(height: KeptSpacing.xl),
              ],
              if (mine.isNotEmpty) ...[
                KeptSectionHeader(l10n.eventsMineSection),
                KeptListGroup(
                  children: [
                    for (final e in mine) _EventRow(event: e, myId: myId),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KeptSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.celebration_outlined, size: 56),
            const SizedBox(height: KeptSpacing.md),
            Text(l10n.eventsEmpty, textAlign: TextAlign.center),
            const SizedBox(height: KeptSpacing.xs),
            Text(
              l10n.eventsEmptyHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: KeptSpacing.md),
            FilledButton(
              onPressed: () => showCreateEventSheet(context),
              child: Text(l10n.eventsCreateCta),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.myId});

  final GiftEvent event;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final label = event.honoreeLabel(l10n.giftAnonymousGiver);
    final date = DateFormat.MMMMd(locale).format(event.eventDate);
    return ListTile(
      leading: KeptAvatar(label: label, avatarValue: event.honoree?.avatarUrl),
      title: Text(
        l10n.eventsRowTitle(label),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        l10n.eventsRowSubtitle(date, event.joined.length),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: event.isOrganizer(myId)
          ? Chip(
              label: Text(l10n.eventsOrganizerBadge),
              visualDensity: VisualDensity.compact,
            )
          : null,
      onTap: () => context.push('/events/${event.id}'),
    );
  }
}

class _InviteRow extends ConsumerWidget {
  const _InviteRow({required this.event});

  final GiftEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final label = event.honoreeLabel(l10n.giftAnonymousGiver);
    final busy = ref.watch(eventsControllerProvider).isLoading;
    final controller = ref.read(eventsControllerProvider.notifier);
    return ListTile(
      leading: KeptAvatar(label: label, avatarValue: event.honoree?.avatarUrl),
      title: Text(
        l10n.eventsInviteTitle(label),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.eventsDecline,
            icon: const Icon(Icons.close),
            onPressed: busy
                ? null
                : () => controller.respond(event.id, join: false),
          ),
          IconButton.filledTonal(
            tooltip: l10n.eventsJoin,
            icon: const Icon(Icons.check),
            onPressed: busy
                ? null
                : () => controller.respond(event.id, join: true),
          ),
        ],
      ),
      onTap: () => context.push('/events/${event.id}'),
    );
  }
}

/// Pick a friend (with a birthday) → open/join the event for their next
/// birthday → land on the event.
Future<void> showCreateEventSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => const _CreateEventSheet(),
  );
}

class _CreateEventSheet extends ConsumerWidget {
  const _CreateEventSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final friends = ref.watch(friendEntriesProvider);
    final busy = ref.watch(eventsControllerProvider).isLoading;
    final today = DateTime.now();
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
                l10n.eventsPickFriendTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Expanded(
            child: friends.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text(l10n.eventsError)),
              data: (entries) {
                final candidates =
                    entries
                        .where(
                          (e) =>
                              e.status == FriendshipStatus.accepted &&
                              e.birthday != null,
                        )
                        .toList()
                      ..sort(
                        (a, b) => daysUntilBirthday(
                          a.birthday!,
                          today,
                        ).compareTo(daysUntilBirthday(b.birthday!, today)),
                      );
                if (candidates.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(KeptSpacing.xl),
                      child: Text(
                        l10n.eventsPickFriendEmpty,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }
                return ListView(
                  children: [
                    for (final f in candidates)
                      ListTile(
                        leading: KeptAvatar(
                          label: f.displayName ?? f.username,
                          avatarValue: f.avatarUrl,
                        ),
                        title: Text(
                          f.displayName ?? f.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          l10n.homeCountdownInDays(
                            daysUntilBirthday(f.birthday!, today),
                          ),
                        ),
                        enabled: !busy,
                        onTap: () => _create(context, ref, f.profileId),
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

  Future<void> _create(
    BuildContext context,
    WidgetRef ref,
    String honoreeId,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    final id = await ref
        .read(eventsControllerProvider.notifier)
        .createOrJoin(honoreeId);
    if (id == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.eventsCreateFailed)));
      return;
    }
    if (navigator.canPop()) navigator.pop();
    await router.push('/events/$id');
  }
}
