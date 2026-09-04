import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';

/// Quick-add sheet (G-83): the center ➕ opens this instead of a tab.
/// Designed to evolve into the V2 camera entry point.
class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => const QuickAddSheet(),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: Text(l10n.quickAddLogGift),
            subtitle: Text(l10n.quickAddLogGiftSubtitle),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/gifts/log');
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: Text(l10n.quickAddWishlist),
            subtitle: Text(l10n.quickAddWishlistSubtitle),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/wishlist/add');
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
