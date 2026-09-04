import 'package:flutter/material.dart';

/// Add-to-wishlist placeholder (G-41): the full form ships with the wishlist
/// feature.
class AddWishlistItemScreen extends StatelessWidget {
  const AddWishlistItemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add to wishlist')),
      body: const Center(child: Text('Wishlist arrives with G-41')),
    );
  }
}
