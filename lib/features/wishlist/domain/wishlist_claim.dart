import 'package:flutter/foundation.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

/// Wire values match `claim_kind`.
enum ClaimKind { solo, shared }

/// One friend's commitment to a group gift — an amount they promised, not
/// money moved (payments are V4). [user] resolves via the discovery card RPC.
@immutable
class Pledge {
  const Pledge({required this.userId, required this.amount, this.user});

  final String userId;
  final double amount;
  final ProfileCard? user;

  String labelOr(String fallback) =>
      user?.displayName ?? user?.username ?? fallback;
}

/// A wishlist item taken care of by a friend of its owner (G-303), either
/// alone or as a pool others pledge into (G-304). The owner never sees one.
@immutable
class WishlistClaim {
  const WishlistClaim({
    required this.id,
    required this.itemId,
    required this.ownerId,
    required this.claimerId,
    required this.kind,
    this.targetAmount,
    this.pledges = const [],
    this.claimer,
    this.giftId,
  });

  /// The gift record this reservation turned into (G-309); null until the
  /// claimer logs it. A pool with a gift is closed.
  final String? giftId;

  bool get hasGift => giftId != null;

  final String id;
  final String itemId;
  final String ownerId;
  final String claimerId;
  final ClaimKind kind;

  /// Optional goal for a pool; null = "whatever we gather".
  final double? targetAmount;
  final List<Pledge> pledges;
  final ProfileCard? claimer;

  bool get isShared => kind == ClaimKind.shared;

  bool isMine(String? userId) => userId != null && claimerId == userId;

  Pledge? pledgeOf(String? userId) =>
      pledges.where((p) => p.userId == userId).firstOrNull;

  double get pledgedTotal => pledges.fold(0, (sum, p) => sum + p.amount);

  String claimerLabelOr(String fallback) =>
      claimer?.displayName ?? claimer?.username ?? fallback;
}
