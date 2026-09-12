import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/presentation/profile_panel.dart';
import 'package:kept/features/safety/application/safety_providers.dart';
import 'package:kept/features/safety/presentation/report_sheet.dart';
import 'package:kept/shared/widgets/kept_action_sheet.dart';

/// Another user's profile (G-84). Sections are RLS-scoped; a friends-only
/// profile renders the private-card state (avatar + name + request button,
/// Instagram-style — G-32). ⋯ menu: block (G-72) / report (G-73).
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({required this.profileId, this.label, super.key});

  final String profileId;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(userProfileProvider(profileId));

    return Scaffold(
      appBar: AppBar(
        title: Text(label ?? ''),
        actions: [_SafetyMenu(profileId: profileId)],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorGeneric)),
        data: (p) {
          if (p == null) {
            return _PrivateProfileBody(profileId: profileId);
          }
          return ProfilePanel(
            profile: p,
            headerTrailing: _FriendshipAction(profileId: profileId),
          );
        },
      ),
    );
  }
}

/// Fallback when the full profile row is RLS-hidden: fetch the minimal card
/// and show it with a private notice + the friendship action. If even the
/// card is missing, the user doesn't exist (deleted) — neutral state.
class _PrivateProfileBody extends ConsumerWidget {
  const _PrivateProfileBody({required this.profileId});

  final String profileId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final card = ref.watch(profileCardProvider(profileId));

    return card.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.errorGeneric)),
      data: (card) {
        if (card == null) {
          return Center(child: Text(l10n.profileNotVisible));
        }
        final name = card.displayName ?? card.username;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  foregroundImage: card.avatarUrl == null
                      ? null
                      : NetworkImage(card.avatarUrl!),
                  child: Text(
                    name.characters.first.toUpperCase(),
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 12),
                Text(name, style: Theme.of(context).textTheme.titleLarge),
                Text(
                  '@${card.username}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                Icon(
                  Icons.lock_outline,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.profilePrivateTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.profilePrivateBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                _FriendshipAction(profileId: profileId),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ⋯ app-bar menu: block (G-72) and report (G-73).
class _SafetyMenu extends ConsumerWidget {
  const _SafetyMenu({required this.profileId});

  final String profileId;

  Future<void> _confirmBlock(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.blockConfirmTitle),
        content: Text(l10n.blockConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.blockAction),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final ok = await ref
        .read(safetyControllerProvider.notifier)
        .block(profileId);
    if (ok) {
      // The profile is invisible to us now — leave it.
      if (navigator.canPop()) navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text(l10n.blockSuccess)));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return IconButton(
      tooltip: l10n.safetyMenuTooltip,
      icon: const Icon(Icons.more_horiz),
      onPressed: () => showKeptActionSheet(
        context,
        actions: [
          KeptSheetAction(
            icon: Icons.block_outlined,
            label: l10n.blockAction,
            destructive: true,
            onTap: () => _confirmBlock(context, ref),
          ),
          KeptSheetAction(
            icon: Icons.flag_outlined,
            label: l10n.reportAction,
            onTap: () => showReportSheet(context, profileId),
          ),
        ],
      ),
    );
  }
}

/// Header action reflecting the friendship state with this user:
/// none → add friend · outgoing → request sent · incoming → accept/decline ·
/// accepted → "Friends" chip.
class _FriendshipAction extends ConsumerWidget {
  const _FriendshipAction({required this.profileId});

  final String profileId;

  /// Accepting (or declining) changes what RLS lets us see of this profile —
  /// refetch it in place so the screen updates without leaving and returning.
  Future<void> _respond(WidgetRef ref, Future<void> Function() action) async {
    await action();
    ref
      ..invalidate(userProfileProvider(profileId))
      ..invalidate(profileCardProvider(profileId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final entries = ref.watch(friendEntriesProvider);
    final controller = ref.read(friendsControllerProvider.notifier);
    final busy = ref.watch(friendsControllerProvider).isLoading;

    return entries.when(
      loading: () => const SizedBox.shrink(),
      error: (error, _) => const SizedBox.shrink(),
      data: (all) {
        final entry = all.where((e) => e.profileId == profileId).firstOrNull;

        if (entry == null) {
          return FilledButton.tonalIcon(
            onPressed: busy ? null : () => controller.sendRequest(profileId),
            icon: const Icon(Icons.person_add_outlined),
            label: Text(l10n.friendAdd),
          );
        }
        return switch ((entry.status, entry.direction)) {
          (FriendshipStatus.accepted, _) => Chip(
            avatar: const Icon(Icons.check, size: 18),
            label: Text(l10n.friendStatusFriends),
          ),
          (FriendshipStatus.pending, RequestDirection.outgoing) => Chip(
            avatar: const Icon(Icons.schedule, size: 18),
            label: Text(l10n.friendPendingOutgoing),
          ),
          (FriendshipStatus.pending, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FilledButton.tonal(
                onPressed: busy
                    ? null
                    : () => _respond(
                        ref,
                        () => controller.accept(entry.friendshipId),
                      ),
                child: Text(l10n.friendAccept),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => _respond(
                        ref,
                        () => controller.decline(entry.friendshipId),
                      ),
                child: Text(l10n.friendDecline),
              ),
            ],
          ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}
