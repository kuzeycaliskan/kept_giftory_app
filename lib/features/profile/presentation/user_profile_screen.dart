import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/presentation/profile_panel.dart';

/// Another user's profile (G-84). Sections are RLS-scoped; a fully hidden
/// profile renders a neutral "not visible" state. The ⋯ block/report menu
/// arrives with G-72/G-73.
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
            return Center(child: Text(l10n.profileNotVisible));
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
        final entry =
            all.where((e) => e.profileId == profileId).firstOrNull;

        if (entry == null) {
          return FilledButton.tonalIcon(
            onPressed:
                busy ? null : () => controller.sendRequest(profileId),
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
