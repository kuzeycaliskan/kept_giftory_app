import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/profile/domain/profile.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';

/// Shared profile body (G-84): header + Wishlist / Gifts / About tabs.
/// Used by the Me tab (own) and the user-profile screen (someone else).
/// The Inventory tab slots in here in V2 (G-204).
class ProfilePanel extends ConsumerWidget {
  const ProfilePanel({
    required this.profile,
    this.isMine = false,
    this.headerTrailing,
    super.key,
  });

  final Profile profile;
  final bool isMine;

  /// Action area under the header (edit button, friendship action…).
  final Widget? headerTrailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          _ProfileHeader(profile: profile, trailing: headerTrailing),
          TabBar(
            tabs: [
              Tab(text: l10n.profileTabWishlist),
              Tab(text: l10n.profileTabHistory),
              Tab(text: l10n.profileTabAbout),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _WishlistTab(profile: profile, isMine: isMine),
                _HistoryTab(profile: profile, isMine: isMine),
                _AboutTab(profile: profile),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, this.trailing});

  final Profile profile;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            child: Text(
              (profile.displayName ?? profile.username)
                  .substring(0, 1)
                  .toUpperCase(),
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            profile.displayName ?? profile.username,
            style: theme.textTheme.titleLarge,
          ),
          Text('@${profile.username}', style: theme.textTheme.bodyMedium),
          if (trailing != null) ...[
            const SizedBox(height: 12),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _WishlistTab extends ConsumerWidget {
  const _WishlistTab({required this.profile, required this.isMine});

  final Profile profile;
  final bool isMine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = isMine
        ? ref.watch(myWishlistProvider)
        : ref.watch(friendWishlistProvider(profile.id));
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.wishlistError)),
      data: (list) => list.isEmpty
          ? Center(
              child: Text(
                isMine ? l10n.wishlistEmptyMine : l10n.wishlistEmptyFriend,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [for (final item in list) _wishlistTile(item)],
            ),
    );
  }

  Widget _wishlistTile(WishlistItem item) => ListTile(
        leading: const Icon(Icons.card_giftcard_outlined),
        title: Text(item.title),
        subtitle: item.note == null ? null : Text(item.note!),
      );
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab({required this.profile, required this.isMine});

  final Profile profile;
  final bool isMine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final items = isMine
        ? ref.watch(receivedGiftsProvider)
        : ref.watch(friendGiftHistoryProvider(profile.id));
    return items.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(l10n.giftsError)),
      data: (list) => list.isEmpty
          ? Center(child: Text(l10n.friendGiftsEmpty))
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final gift in list) _giftTile(context, l10n, locale, gift),
              ],
            ),
    );
  }

  Widget _giftTile(
    BuildContext context,
    AppLocalizations l10n,
    String locale,
    GiftEntry gift,
  ) =>
      ListTile(
        leading: const Icon(Icons.redeem_outlined),
        title: Text(gift.item),
        subtitle: Text(
          '${gift.counterpartLabel ?? l10n.giftAnonymousGiver} · '
          '${DateFormat.yMMMd(locale).format(gift.giftDate)}',
        ),
      );
}

class _AboutTab extends StatelessWidget {
  const _AboutTab({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final rows = <Widget>[
      if (profile.bio != null)
        ListTile(
          leading: const Icon(Icons.notes_outlined),
          title: Text(profile.bio!),
        ),
      if (profile.birthday != null)
        ListTile(
          leading: const Icon(Icons.cake_outlined),
          title: Text(l10n.profileAboutBirthday),
          subtitle: Text(
            DateFormat.MMMMd(locale).format(profile.birthday!),
          ),
        ),
      if (profile.occupation != null)
        ListTile(
          leading: const Icon(Icons.work_outline),
          title: Text(l10n.profileAboutOccupation),
          subtitle: Text(profile.occupation!),
        ),
    ];
    if (rows.isEmpty) {
      return Center(child: Text(l10n.profileAboutEmpty));
    }
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: rows,
    );
  }
}
