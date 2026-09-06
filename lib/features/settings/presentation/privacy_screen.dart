import 'package:flutter/material.dart' hide Visibility;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/settings/application/privacy_settings_controller.dart';

/// Section-based visibility settings (G-22): who can see the profile,
/// wishlist and gift history. Values live on the profile row; RLS enforces
/// them server-side, so a change takes effect immediately for everyone.
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final profile = ref.watch(myProfileProvider);
    final saving = ref.watch(privacySettingsControllerProvider).isLoading;

    ref.listen(privacySettingsControllerProvider, (previous, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.privacyUpdateError)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.privacyTitle)),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.meProfileError)),
        data: (profile) {
          if (profile == null) {
            return Center(child: Text(l10n.meProfileError));
          }
          void set(PrivacySection section, Visibility value) {
            ref
                .read(privacySettingsControllerProvider.notifier)
                .setVisibility(section, value);
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text(
                  l10n.privacyIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              _VisibilityTile(
                title: l10n.privacyProfile,
                subtitle: l10n.privacyProfileDesc,
                value: profile.profileVisibility,
                // The profile itself can't go fully private: friend requests
                // and search need a minimal public surface (PBI G-22).
                allowPrivate: false,
                enabled: !saving,
                onChanged: (value) => set(PrivacySection.profile, value),
              ),
              _VisibilityTile(
                title: l10n.privacyWishlist,
                subtitle: l10n.privacyWishlistDesc,
                value: profile.wishlistVisibility,
                enabled: !saving,
                onChanged: (value) => set(PrivacySection.wishlist, value),
              ),
              _VisibilityTile(
                title: l10n.privacyGiftHistory,
                subtitle: l10n.privacyGiftHistoryDesc,
                value: profile.giftHistoryVisibility,
                enabled: !saving,
                onChanged: (value) => set(PrivacySection.giftHistory, value),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _VisibilityTile extends StatelessWidget {
  const _VisibilityTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.allowPrivate = true,
  });

  final String title;
  final String subtitle;
  final Visibility value;
  final bool enabled;
  final bool allowPrivate;
  final ValueChanged<Visibility> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          SegmentedButton<Visibility>(
            segments: [
              ButtonSegment(
                value: Visibility.public,
                label: Text(l10n.visibilityPublic),
              ),
              ButtonSegment(
                value: Visibility.friends,
                label: Text(l10n.visibilityFriends),
              ),
              if (allowPrivate)
                ButtonSegment(
                  value: Visibility.private,
                  label: Text(l10n.visibilityPrivate),
                ),
            ],
            selected: {value},
            onSelectionChanged: enabled
                ? (selection) => onChanged(selection.single)
                : null,
          ),
        ],
      ),
    );
  }
}
