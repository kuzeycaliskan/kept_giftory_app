import 'package:flutter/foundation.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';

/// Real V1 activity: my own social events (Home "activity").
enum HomeEventKind {
  friendAccepted,

  /// A member logged a gift for me (actor = giver; null once anonymized).
  giftReceived,

  /// I logged a gift from someone outside Kept (G-212) — my own record,
  /// labelled by relation instead of a profile.
  externalGiftLogged,

  /// A friend received a gift (their history visibility applies; pending
  /// surprises never reach the feed).
  friendGiftReceived,
}

/// "Something is coming": the only two facts the recipient may know about
/// pending surprises (G-210 decision) — that one exists and when it opens.
@immutable
class SurpriseTeaser {
  const SurpriseTeaser({required this.nextRevealAt});

  final DateTime nextRevealAt;
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
    this.gift,
    this.recipientId,
    this.recipientLabel,
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

  /// Full gift for card rendering (photos, link, note). Counterpart = giver.
  final GiftEntry? gift;

  /// Who received it (friend events); null for my own events.
  final String? recipientId;
  final String? recipientLabel;
}
