import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/presentation/profile_panel.dart';

/// Me tab (G-84): the signed-in user's profile hub — header + friend count,
/// quick links (wishlist / friends / settings) and the profile tabs.
class MeScreen extends ConsumerWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(myProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.meTitle),
        actions: [
          IconButton(
            tooltip: l10n.meSettings,
            icon: const Icon(Icons.settings_outlined),
            // Settings center is G-85.
            onPressed: null,
          ),
        ],
      ),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.meProfileError)),
        data: (p) {
          if (p == null) {
            // Onboarding incomplete / backend-less: neutral fallback.
            return Center(child: Text(l10n.meProfileFallback));
          }
          return Column(
            children: [
              Expanded(
                child: ProfilePanel(
                  profile: p,
                  isMine: true,
                  headerTrailing: const _MeQuickLinks(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Friend count + quick navigation under the own-profile header.
class _MeQuickLinks extends ConsumerWidget {
  const _MeQuickLinks();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final friendCount = ref.watch(friendEntriesProvider).maybeWhen(
          data: (all) => all
              .where((e) => e.status == FriendshipStatus.accepted)
              .length,
          orElse: () => null,
        );

    return Column(
      children: [
        if (friendCount != null)
          Text(
            l10n.profileFriendCount(friendCount),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          alignment: WrapAlignment.center,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => context.push('/wishlist'),
              icon: const Icon(Icons.star_outline, size: 18),
              label: Text(l10n.wishlistMineTitle),
            ),
            FilledButton.tonalIcon(
              onPressed: () => context.push('/friends'),
              icon: const Icon(Icons.group_outlined, size: 18),
              label: Text(l10n.meFriends),
            ),
          ],
        ),
      ],
    );
  }
}
