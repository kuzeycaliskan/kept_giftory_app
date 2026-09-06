import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/presentation/profile_panel.dart';

/// Another user's profile (G-84). Sections are RLS-scoped; a friends-only
/// profile renders the private-card state (avatar + name + request button,
/// Instagram-style — G-32). The ⋯ block/report menu arrives with G-72/G-73.
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({required this.profileId, this.label, super.key});

  final String profileId;
  final String? label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(userProfileProvider(profileId));

    return Scaffold(
      appBar: AppBar(title: Text(label ?? '')),
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

/// Header action reflecting the friendship state with this user:
/// none → add friend · outgoing → request sent · incoming → accept/decline ·
/// accepted → "Friends" chip.
class _FriendshipAction extends ConsumerWidget {
  const _FriendshipAction({required this.profileId});

  final String profileId;

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
                    : () => controller.accept(entry.friendshipId),
                child: Text(l10n.friendAccept),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: busy
                    ? null
                    : () => controller.decline(entry.friendshipId),
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
