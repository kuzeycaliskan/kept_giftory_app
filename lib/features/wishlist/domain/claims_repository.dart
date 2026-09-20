import 'package:kept/core/error/result.dart';
import 'package:kept/features/wishlist/domain/wishlist_claim.dart';

/// Reservations and group gifts on a friend's wishlist (V3.0-b). Who may
/// see or touch a claim is RLS's call: the owner gets nothing, friends of
/// the owner get everything on that list.
abstract interface class ClaimsRepository {
  /// Claims on [ownerId]'s list, keyed by wishlist item id.
  Future<Result<Map<String, WishlistClaim>>> fetchForOwner(String ownerId);

  /// Take the item — alone, or open a pool. `ConflictFailure` when someone
  /// was faster (one claim per item).
  Future<Result<WishlistClaim>> claim(
    String itemId, {
    required ClaimKind kind,
    double? targetAmount,
  });

  /// Drop the claim (and its pledges). Claimer only (RLS).
  Future<Result<void>> release(String claimId);

  /// Turn a solo claim into a pool. Claimer only; irreversible by design.
  Future<Result<void>> makeShared(String claimId, {double? targetAmount});

  /// Set (or replace) my pledge on a pool.
  Future<Result<void>> pledge(String claimId, double amount);

  /// Remove a pledge: mine, or anyone's when I organise the pool.
  Future<Result<void>> withdrawPledge(String claimId, String userId);
}
