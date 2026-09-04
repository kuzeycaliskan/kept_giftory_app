import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.card_giftcard),
            title: const Text('Log a gift'),
            subtitle: const Text('I bought a gift for a friend'),
            onTap: () {
              Navigator.of(context).pop();
              context.push('/gifts/log');
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Add to wishlist'),
            subtitle: const Text('Something I want'),
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
