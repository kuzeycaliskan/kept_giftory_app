import 'package:flutter/foundation.dart';

/// A friend's recent wishlist addition (Home "from friends' wishlists").
@immutable
class FriendWishlistItem {
  const FriendWishlistItem({
    required this.itemId,
    required this.title,
    required this.ownerId,
    required this.ownerUsername,
    required this.createdAt,
    this.ownerDisplayName,
  });

  final String itemId;
  final String title;
  final String ownerId;
  final String ownerUsername;
  final String? ownerDisplayName;
  final DateTime createdAt;

  String get ownerLabel => ownerDisplayName ?? ownerUsername;
}

/// Real V1 activity: my own social events (Home "activity").
enum HomeEventKind { friendAccepted, giftReceived }

@immutable
class HomeEvent {
  const HomeEvent({
    required this.kind,
    required this.at,
    this.actorId,
    this.actorLabel,
  });

  final HomeEventKind kind;
  final DateTime at;

  /// Counterpart profile — null when the account was deleted (anonymized).
  final String? actorId;
  final String? actorLabel;
}
