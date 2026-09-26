import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/wishlist/application/claims_providers.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/features/wishlist/domain/wishlist_claim.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/features/wishlist/presentation/claim_bar.dart';
import 'package:kept/features/wishlist/presentation/wishlist_item_tile.dart';

/// A friend's wishlist with reservation strips, as a non-scrolling block
/// for embedding (the event's "Gift ideas" section). Loading, empty and
/// error states are inline so the host list keeps its own scroll.
class ClaimableWishlist extends ConsumerWidget {
  const ClaimableWishlist({
    required this.ownerId,
    required this.ownerLabel,
    this.eventId,
    super.key,
  });

  final String ownerId;
  final String ownerLabel;

  /// The event this list is shown in; gift records link to it.
  final String? eventId;

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
            for (final item in list)
              if (claims.hasError)
                WishlistItemTile(item: item)
              else
                ClaimableItemRow(
                  item: item,
                  claim: claims.valueOrNull?[item.id],
                  eventId: eventId,
                ),
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

/// One wishlist entry with its reservation strip, framed together so the
/// strip's buttons visibly belong to that product and not the next one.
class ClaimableItemRow extends StatelessWidget {
  const ClaimableItemRow({
    required this.item,
    required this.claim,
    this.eventId,
    super.key,
  });

  final WishlistItem item;
  final WishlistClaim? claim;
  final String? eventId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KeptSpacing.xs),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: KeptRadius.cardAll,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            KeptSpacing.sm,
            KeptSpacing.sm,
            KeptSpacing.sm,
            KeptSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WishlistItemTile(item: item),
              ClaimBar(item: item, claim: claim, eventId: eventId),
            ],
          ),
        ),
      ),
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
