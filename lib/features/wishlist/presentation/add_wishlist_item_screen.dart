import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';

/// Add-to-wishlist placeholder (G-41): the full form ships with the wishlist
/// feature.
class AddWishlistItemScreen extends StatelessWidget {
  const AddWishlistItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.wishlistAddTitle)),
      body: Center(child: Text(l10n.wishlistComingSoon)),
    );
  }
}
