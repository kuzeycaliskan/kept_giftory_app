import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';

/// Gifts tab placeholder. Real content (given/received lists, gift detail)
/// lands with G-51/G-52; in V3 this evolves into the event hub.
class GiftsScreen extends StatelessWidget {
  const GiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.giftsTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.card_giftcard_outlined, size: 56),
            const SizedBox(height: 12),
            Text(l10n.giftsEmpty),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => context.push('/gifts/log'),
              child: Text(l10n.giftsLogFirst),
            ),
          ],
        ),
      ),
    );
  }
}
