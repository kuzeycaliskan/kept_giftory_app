import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';

/// Friends screen (G-31): incoming/outgoing requests + accepted friends.
/// Search (G-32) and contact matching (G-33) will extend this screen.
class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final entries = ref.watch(friendEntriesProvider);

    ref.listen(friendsControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.friendsTitle)),
      body: entries.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.friendsError)),
        data: (all) {
          final requests = all
              .where((e) => e.status == FriendshipStatus.pending)
              .toList();
          final friends = all
              .where((e) => e.status == FriendshipStatus.accepted)
              .toList();

          if (all.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.group_outlined, size: 56),
                    const SizedBox(height: 12),
                    Text(l10n.friendsEmpty),
                    const SizedBox(height: 4),
                    Text(
                      l10n.friendsEmptyHint,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(friendEntriesProvider);
              await ref.read(friendEntriesProvider.future);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                if (requests.isNotEmpty) ...[
                  _SectionLabel(l10n.friendsRequestsSection),
                  for (final e in requests) _RequestTile(entry: e),
                  if (friends.isNotEmpty) const Divider(),
                ],
                for (final e in friends) _FriendTile(entry: e),
              ],
            ),
          );
        },
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

class _Avatar extends StatelessWidget {
  const _Avatar({required this.entry});

  final FriendEntry entry;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Text(entry.label.substring(0, 1).toUpperCase()),
    );
  }
}

/// Colored swipe background for [Dismissible] rows.
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.icon,
    required this.color,
    required this.alignment,
  });

  final IconData icon;
  final Color color;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Align(
        alignment: alignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(icon, color: Theme.of(context).colorScheme.onPrimary),
        ),
      ),
    );
  }
}

class _RequestTile extends ConsumerWidget {
  const _RequestTile({required this.entry});

  final FriendEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final controller = ref.read(friendsControllerProvider.notifier);
    final busy = ref.watch(friendsControllerProvider).isLoading;
    final incoming = entry.direction == RequestDirection.incoming;
    final colors = Theme.of(context).colorScheme;

    final tile = ListTile(
      leading: _Avatar(entry: entry),
      title: Text(entry.label),
      subtitle: Text(
        incoming ? '@${entry.username}' : l10n.friendPendingOutgoing,
      ),
      trailing: incoming
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: l10n.friendAccept,
                  icon: const Icon(Icons.check_circle_outline),
                  onPressed:
                      busy ? null : () => controller.accept(entry.friendshipId),
                ),
                IconButton(
                  tooltip: l10n.friendDecline,
                  icon: const Icon(Icons.cancel_outlined),
                  onPressed: busy
                      ? null
                      : () => controller.decline(entry.friendshipId),
                ),
              ],
            )
          : TextButton(
              onPressed:
                  busy ? null : () => controller.remove(entry.friendshipId),
              child: Text(l10n.friendCancelRequest),
            ),
    );

    if (incoming) {
      // Swipe right = accept, swipe left = decline (buttons stay as the
      // discoverable/accessible path; gestures are accelerators).
      return Dismissible(
        key: ValueKey('request-${entry.friendshipId}'),
        background: _SwipeBackground(
          icon: Icons.check,
          color: colors.primary,
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: _SwipeBackground(
          icon: Icons.close,
          color: colors.error,
          alignment: Alignment.centerRight,
        ),
        confirmDismiss: (direction) async {
          if (busy) return false;
          if (direction == DismissDirection.startToEnd) {
            await controller.accept(entry.friendshipId);
          } else {
            await controller.decline(entry.friendshipId);
          }
          return true;
        },
        child: tile,
      );
    }

    // Outgoing: swipe left = cancel the request.
    return Dismissible(
      key: ValueKey('request-${entry.friendshipId}'),
      direction: DismissDirection.endToStart,
      background: _SwipeBackground(
        icon: Icons.undo,
        color: colors.error,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (_) async {
        if (busy) return false;
        await controller.remove(entry.friendshipId);
        return true;
      },
      child: tile,
    );
  }
}

class _FriendTile extends ConsumerWidget {
  const _FriendTile({required this.entry});

  final FriendEntry entry;

  /// True when the user confirms; the caller performs the removal.
  Future<bool> _confirmRemove(BuildContext context) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.friendRemoveConfirmTitle),
        content: Text(l10n.friendRemoveConfirmBody(entry.label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.friendRemove),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  Future<bool> _confirmAndRemove(BuildContext context, WidgetRef ref) async {
    final confirmed = await _confirmRemove(context);
    if (confirmed) {
      await ref
          .read(friendsControllerProvider.notifier)
          .remove(entry.friendshipId);
    }
    return confirmed;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    // Native gesture: swipe left to remove (confirm dialog guards it).
    // Long-press is the secondary/accessible path to the same action.
    return Dismissible(
      key: ValueKey('friend-${entry.friendshipId}'),
      direction: DismissDirection.endToStart,
      background: _SwipeBackground(
        icon: Icons.person_remove_outlined,
        color: colors.error,
        alignment: Alignment.centerRight,
      ),
      confirmDismiss: (_) => _confirmAndRemove(context, ref),
      child: ListTile(
        leading: _Avatar(entry: entry),
        title: Text(entry.label),
        subtitle: Text('@${entry.username}'),
        onLongPress: () => _confirmAndRemove(context, ref),
      ),
    );
  }
}
