import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/events/application/events_providers.dart';
import 'package:kept/features/events/domain/event_kind.dart';
import 'package:kept/features/events/domain/gift_event.dart';
import 'package:kept/features/events/presentation/event_kind_labels.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/home/domain/birthday_math.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';
import 'package:kept/shared/widgets/kept_date_picker.dart';
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
    final myId = ref.watch(myProfileProvider).value?.id;
    return events.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.eventsError)),
      data: (list) {
        final invites = list.where((e) => e.isInvited(myId)).toList();
        final forYou = list.where((e) => e.isHonoree(myId)).toList();
        final others = list.where(
          (e) => !e.isInvited(myId) && !e.isHonoree(myId),
        );
        final mine = others.where((e) => e.isOpen).toList();
        // Revealed events are an archive: still readable, no longer joined
        // or left.
        final past = others.where((e) => e.isRevealed).toList();
        Future<void> refresh() async {
          ref.invalidate(myEventsProvider);
          await ref.read(myEventsProvider.future);
        }

        if (list.isEmpty) {
          // Scrollable so pull-to-refresh works on the empty state too.
          return RefreshIndicator(
            onRefresh: refresh,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: constraints.maxHeight,
                  child: const _EmptyState(),
                ),
              ),
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              KeptSpacing.lg,
              KeptSpacing.sm,
              KeptSpacing.lg,
              88,
            ),
            children: [
              if (forYou.isNotEmpty) ...[
                KeptSectionHeader(l10n.eventsForYouSection),
                KeptListGroup(
                  children: [for (final e in forYou) _ForYouRow(event: e)],
                ),
                const SizedBox(height: KeptSpacing.xl),
              ],
              if (invites.isNotEmpty) ...[
                KeptSectionHeader(l10n.eventsInvitesSection),
                KeptListGroup(
                  children: [for (final e in invites) EventInviteRow(event: e)],
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
              if (past.isNotEmpty) ...[
                if (mine.isNotEmpty) const SizedBox(height: KeptSpacing.xl),
                KeptSectionHeader(l10n.eventsPastSection),
                KeptListGroup(
                  children: [
                    for (final e in past) _EventRow(event: e, myId: myId),
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
        event.label(l10n),
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

/// The honoree's own revealed event (G-307).
class _ForYouRow extends StatelessWidget {
  const _ForYouRow({required this.event});

  final GiftEvent event;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final date = DateFormat.MMMMd(locale).format(event.eventDate);
    return ListTile(
      leading: KeptIconBadge(event.kind.icon),
      title: Text(
        event.honoreeFacingLabel(l10n),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        l10n.eventsRowSubtitle(date, event.joined.length),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: event.thanksNote == null
          ? const Icon(Icons.chevron_right)
          : const Icon(Icons.favorite, size: 18),
      onTap: () => context.push('/events/${event.id}'),
    );
  }
}

/// Invitation row with accept/decline — the hub and the Activity center
/// (bell) render the same row so an invite reads like a friend request.
class EventInviteRow extends ConsumerWidget {
  const EventInviteRow({required this.event, super.key});

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
        l10n.eventsInviteTitle(event.label(l10n)),
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
                : () async {
                    // Accepting lands you in the event — no second tap.
                    final ok = await controller.respond(event.id, join: true);
                    if (ok && context.mounted) {
                      unawaited(context.push('/events/${event.id}'));
                    }
                  },
          ),
        ],
      ),
      onTap: () => context.push('/events/${event.id}'),
    );
  }
}

/// Pick a friend → pick the occasion → (date, title) → open/join → land on
/// the event (G-410). Birthday keeps its date from the profile.
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
                // Every friend qualifies now; birthdays sort first by
                // closeness, the rest alphabetically after them.
                final candidates =
                    entries
                        .where((e) => e.status == FriendshipStatus.accepted)
                        .toList()
                      ..sort((a, b) {
                        final da = a.birthday == null
                            ? null
                            : daysUntilBirthday(a.birthday!, today);
                        final db = b.birthday == null
                            ? null
                            : daysUntilBirthday(b.birthday!, today);
                        if (da != null && db != null) return da.compareTo(db);
                        if (da != null) return -1;
                        if (db != null) return 1;
                        return (a.displayName ?? a.username).compareTo(
                          b.displayName ?? b.username,
                        );
                      });
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
                        subtitle: f.birthday == null
                            ? null
                            : Text(
                                l10n.eventsBirthdayInDays(
                                  daysUntilBirthday(f.birthday!, today),
                                ),
                              ),
                        enabled: !busy,
                        onTap: () => _pickKind(context, ref, f),
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

  /// Second step: the occasion. Birthday is offered only when the profile
  /// has one (the server would refuse anyway).
  Future<void> _pickKind(
    BuildContext context,
    WidgetRef ref,
    FriendEntry friend,
  ) async {
    final l10n = context.l10n;
    final kind = await showModalBottomSheet<EventKind>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      // Eight occasions outgrow a short screen: the list scrolls under a
      // cap taken from layout, not MediaQuery.
      isScrollControlled: true,
      builder: (sheetContext) => LayoutBuilder(
        builder: (_, constraints) => ConstrainedBox(
          constraints: BoxConstraints(maxHeight: constraints.maxHeight * 0.85),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: KeptSpacing.lg),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  KeptSpacing.lg,
                  0,
                  KeptSpacing.lg,
                  KeptSpacing.sm,
                ),
                child: Text(
                  l10n.eventsPickKindTitle(
                    friend.displayName ?? friend.username,
                  ),
                  style: Theme.of(sheetContext).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              for (final k in EventKind.values)
                ListTile(
                  leading: KeptIconBadge(k.icon),
                  title: Text(k.label(l10n)),
                  subtitle: k.isBirthday && friend.birthday == null
                      ? Text(l10n.eventsKindNeedsBirthday)
                      : null,
                  enabled: !(k.isBirthday && friend.birthday == null),
                  onTap: () => Navigator.of(sheetContext).pop(k),
                ),
            ],
          ),
        ),
      ),
    );
    if (kind == null || !context.mounted) return;

    DateTime? date;
    if (!kind.isBirthday) {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      date = await showKeptDatePicker(
        context,
        initialDate: start,
        firstDate: start,
        lastDate: start.add(eventMaxLeadTime),
      );
      if (date == null || !context.mounted) return;
    }

    String? title;
    if (kind.needsTitle) {
      title = await _askTitle(context);
      if (title == null || !context.mounted) return;
    }

    await _create(context, ref, friend.profileId, kind, date, title);
  }

  Future<String?> _askTitle(BuildContext context) => showDialog<String>(
    context: context,
    builder: (_) => const _TitleDialog(),
  );

  Future<void> _create(
    BuildContext context,
    WidgetRef ref,
    String honoreeId,
    EventKind kind,
    DateTime? date,
    String? title,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final navigator = Navigator.of(context);
    final id = await ref
        .read(eventsControllerProvider.notifier)
        .createOrJoin(honoreeId, kind: kind, date: date, title: title);
    if (id == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.eventsCreateFailed)));
      return;
    }
    if (navigator.canPop()) navigator.pop();
    await router.push('/events/$id');
  }
}

/// Names an "other" occasion. Owns its controller so the dialog's exit
/// animation never touches a disposed one.
class _TitleDialog extends StatefulWidget {
  const _TitleDialog();

  @override
  State<_TitleDialog> createState() => _TitleDialogState();
}

class _TitleDialogState extends State<_TitleDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.eventsTitleTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: eventTitleMaxLength,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: l10n.eventsTitleHint),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isEmpty) return;
            Navigator.of(context).pop(text);
          },
          child: Text(l10n.commonDone),
        ),
      ],
    );
  }
}
