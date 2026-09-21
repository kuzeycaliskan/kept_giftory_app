import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/wishlist/application/claims_providers.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/presentation/claim_bar.dart';
import 'package:kept/features/wishlist/presentation/wishlist_item_tile.dart';

/// A friend's wishlist with reservation strips, as a non-scrolling block
/// for embedding (the event's "Gift ideas" section). Loading, empty and
/// error states are inline so the host list keeps its own scroll.
class ClaimableWishlist extends ConsumerWidget {
  const ClaimableWishlist({
    required this.ownerId,
    required this.ownerLabel,
    super.key,
  });

  final String ownerId;
  final String ownerLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final items = ref.watch(friendWishlistProvider(ownerId));
    final claims = ref.watch(wishlistClaimsProvider(ownerId));
    ref.listen(friendWishlistProvider(ownerId), (_, next) {
      next.whenData(
        (list) => refreshPreviewsOf(ref, list, friendWishlistProvider(ownerId)),
      );
    });
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return items.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(KeptSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: KeptSpacing.sm),
        child: Text(l10n.wishlistError, style: muted),
      ),
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: KeptSpacing.sm),
            child: Text(l10n.claimsIdeasEmpty, style: muted),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (claims.hasError) ClaimsErrorRow(ownerId: ownerId),
            for (final item in list) ...[
              WishlistItemTile(item: item),
              if (!claims.hasError)
                ClaimBar(item: item, claim: claims.valueOrNull?[item.id]),
            ],
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => context.push(
                  '/users/$ownerId/wishlist'
                  '?name=${Uri.encodeComponent(ownerLabel)}',
                ),
                child: Text(l10n.claimsIdeasSeeAll),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Reservations failed to load while the items did: say so and offer a
/// retry rather than pretending nothing is reserved.
class ClaimsErrorRow extends ConsumerWidget {
  const ClaimsErrorRow({required this.ownerId, super.key});

  final String ownerId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: KeptSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.error_outline, size: 18, color: scheme.error),
          const SizedBox(width: KeptSpacing.sm),
          Expanded(
            child: Text(
              l10n.claimsError,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
          TextButton(
            onPressed: () => ref.invalidate(wishlistClaimsProvider(ownerId)),
            child: Text(l10n.commonRetry),
          ),
        ],
      ),
    );
  }
}
