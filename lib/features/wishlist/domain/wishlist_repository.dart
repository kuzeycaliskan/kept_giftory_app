import 'package:kept/core/error/result.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';

/// Wishlist boundary (G-41/G-42). Reads of other users' lists are subject to
/// their `wishlist_visibility` via RLS — the UI never enforces visibility.
abstract interface class WishlistRepository {
  Future<Result<List<WishlistItem>>> fetchMine();

  /// A friend's list; RLS returns only what the caller may see.
  Future<Result<List<WishlistItem>>> fetchFor(String profileId);

  /// Photo attachment lands with the V2 media pipeline (G-207).
  Future<Result<WishlistItem>> add({
    required String title,
    String? note,
    String? url,
  });

  Future<Result<void>> delete(String itemId);
}
