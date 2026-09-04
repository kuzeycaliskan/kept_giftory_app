import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';

/// Wishlist screen (G-41/G-42) — one widget, two modes:
///  * mine (`ownerId == null`): editable — FAB add + swipe-to-delete;
///  * a friend's (`ownerId` set): read-only, RLS-scoped.
class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({this.ownerId, this.ownerLabel, super.key});

  /// Null = the signed-in user's own list.
  final String? ownerId;

  /// Display name for a friend's list title.
  final String? ownerLabel;

  bool get _isMine => ownerId == null;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final items = _isMine
        ? ref.watch(myWishlistProvider)
        : ref.watch(friendWishlistProvider(ownerId!));

    ref.listen(wishlistControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isMine
              ? l10n.wishlistMineTitle
              : l10n.wishlistOfUser(ownerLabel ?? ''),
        ),
        actions: [
          // While picking a gift, check what they already received (G-52).
          if (!_isMine)
            IconButton(
              tooltip: l10n.giftHistoryTooltip,
              icon: const Icon(Icons.history),
              onPressed: () => context.push(
                '/users/$ownerId/gifts'
                '?name=${Uri.encodeComponent(ownerLabel ?? '')}',
              ),
            ),
        ],
      ),
      floatingActionButton: _isMine
          ? FloatingActionButton(
              tooltip: l10n.wishlistAddTitle,
              onPressed: () => context.push('/wishlist/add'),
              child: const Icon(Icons.add),
            )
          : null,
      body: items.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.wishlistError)),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star_outline, size: 56),
                    const SizedBox(height: 12),
                    Text(
                      _isMine
                          ? l10n.wishlistEmptyMine
                          : l10n.wishlistEmptyFriend,
                    ),
                    if (_isMine) ...[
                      const SizedBox(height: 4),
                      Text(
                        l10n.wishlistEmptyMineHint,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              if (_isMine) {
                ref.invalidate(myWishlistProvider);
                await ref.read(myWishlistProvider.future);
              } else {
                ref.invalidate(friendWishlistProvider(ownerId!));
                await ref.read(friendWishlistProvider(ownerId!).future);
              }
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                for (final item in list)
                  _isMine
                      ? _DismissibleItemTile(item: item)
                      : _ItemTile(item: item),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final WishlistItem item;

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if (item.note != null) item.note!,
      if (item.url != null) item.url!,
    ];
    return ListTile(
      leading: const Icon(Icons.card_giftcard_outlined),
      title: Text(item.title),
      subtitle: subtitleParts.isEmpty
          ? null
          : Text(
              subtitleParts.join('\n'),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
    );
  }
}

/// Own-list tile with the house swipe gesture: swipe left to delete.
class _DismissibleItemTile extends ConsumerWidget {
  const _DismissibleItemTile({required this.item});

  final WishlistItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Dismissible(
      key: ValueKey('wishlist-${item.id}'),
      direction: DismissDirection.endToStart,
      background: ColoredBox(
        color: colors.error,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Icon(Icons.delete_outline, color: colors.onError),
          ),
        ),
      ),
      confirmDismiss: (_) async {
        await ref.read(wishlistControllerProvider.notifier).delete(item.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.wishlistDeletedSnack)),
          );
        }
        return true;
      },
      child: _ItemTile(item: item),
    );
  }
}
