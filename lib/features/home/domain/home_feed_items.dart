import 'package:flutter/foundation.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';

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
enum HomeEventKind {
  friendAccepted,

  /// A member logged a gift for me (actor = giver; null once anonymized).
  giftReceived,

  /// I logged a gift from someone outside Kept (G-212) — my own record,
  /// labelled by relation instead of a profile.
  externalGiftLogged,
}

@immutable
class HomeEvent {
  const HomeEvent({
    required this.kind,
    required this.at,
    this.actorId,
    this.actorLabel,
    this.giverRelation,
    this.item,
  }) : assert(
         kind != HomeEventKind.externalGiftLogged || giverRelation != null,
         'an external gift event carries its relation',
       );

  final HomeEventKind kind;
  final DateTime at;

  /// Counterpart profile — null when the account was deleted (anonymized).
  final String? actorId;
  final String? actorLabel;

  /// Who gave an external gift (only for [HomeEventKind.externalGiftLogged]).
  final GiftRelation? giverRelation;

  /// Gift name for gift events (already RLS-safe: unrevealed surprises never
  /// reach the client).
  final String? item;
}
