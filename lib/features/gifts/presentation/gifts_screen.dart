import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Gifts tab placeholder. Real content (given/received lists, gift detail)
/// lands with G-51/G-52; in V3 this evolves into the event hub.
class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gifts')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard_outlined, size: 56),
            const SizedBox(height: 12),
            const Text('No gifts logged yet'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.push('/gifts/log'),
              child: const Text('Log your first gift'),
            ),
          ],
        ),
      ),
    );
  }
}
