import 'package:flutter/foundation.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/shared/domain/reaction.dart';

/// Who gave an externally-logged gift (G-212). Wire names match the
/// `giver_relation` Postgres enum; the UI localizes labels.
enum GiftRelation {
  mother,
  father,
  sibling,
  partner,
  relative,
  friend,
  coworker,
  other,
}

/// Storage bucket for gift photos (private; readable through a visible
/// gift_photos row only).
const String giftMediaBucket = 'gift-media';

/// Photos per gift — mirrors the `enforce_gift_photo_cap` trigger.
const int giftPhotoCap = 3;

/// One photo attached to a gift; either party may have added it.
@immutable
class GiftPhoto {
  const GiftPhoto({
    required this.id,
    required this.giftId,
    required this.uploaderId,
    required this.mediaPath,
    required this.createdAt,
  });

  final String id;
  final String giftId;
  final String uploaderId;
  final String mediaPath;
  final DateTime createdAt;
}

/// Someone who chipped into a group gift (G-309): snapshot of the pool's
/// pledgers when the organizer logged it. The label resolves through the
/// profiles embed (null for a private profile → "a friend").
@immutable
class GiftContributor {
  const GiftContributor({required this.userId, this.amount, this.label});

  final String userId;
  final double? amount;
  final String? label;
}

/// A gift row shaped for the UI: the counterpart is already resolved
/// (recipient when listing given gifts, giver when listing received/history).
/// A null [counterpartLabel] means the giver deleted their account (G-71
/// anonymization) — the UI shows a localized fallback.
@immutable
class GiftEntry {
  const GiftEntry({
    required this.id,
    required this.item,
    required this.giftDate,
    required this.isSurprise,
    this.note,
    this.revealAt,
    this.counterpartId,
    this.counterpartLabel,
    this.preview,
    this.giverRelation,
    this.photos = const [],
    this.giverId,
    this.recipientId,
    this.reactions = const [],
    this.commentCount = 0,
    this.contributors = const [],
  });

  /// Group gift: the friends behind [giverId] (never includes the giver).
  final List<GiftContributor> contributors;

  final String id;
  final String item;
  final String? note;
  final DateTime giftDate;
  final bool isSurprise;
  final DateTime? revealAt;
  final String? counterpartId;
  final String? counterpartLabel;

  /// Attached product preview (G-211); null for free-text gifts.
  final LinkPreview? preview;

  /// Set on self-logged external gifts (G-212): the giver isn't a member.
  /// Distinct from a null [counterpartLabel] with null relation, which means
  /// a DELETED member (anonymized).
  final GiftRelation? giverRelation;

  /// Attached photos, oldest first (max [giftPhotoCap]).
  final List<GiftPhoto> photos;

  /// Raw party ids (giver null = external or deleted member). The detail
  /// screen derives "may I add photos" from these, independent of which
  /// list the gift was opened from.
  final String? giverId;
  final String? recipientId;

  bool isParty(String? userId) =>
      userId != null && (userId == giverId || userId == recipientId);

  /// Reactions from everyone who can see the gift (one per user).
  final List<Reaction> reactions;

  /// Number of comments (visible ones); the list loads on demand.
  final int commentCount;

  ReactionKind? reactionOf(String? userId) =>
      reactions.where((r) => r.userId == userId).firstOrNull?.kind;

  Map<ReactionKind, int> get reactionCounts => {
    for (final kind in ReactionKind.values)
      if (reactions.any((r) => r.kind == kind))
        kind: reactions.where((r) => r.kind == kind).length,
  };

  GiftEntry copyWith({
    List<GiftPhoto>? photos,
    List<Reaction>? reactions,
    int? commentCount,
  }) => GiftEntry(
    id: id,
    item: item,
    giftDate: giftDate,
    isSurprise: isSurprise,
    note: note,
    revealAt: revealAt,
    counterpartId: counterpartId,
    counterpartLabel: counterpartLabel,
    preview: preview,
    giverRelation: giverRelation,
    photos: photos ?? this.photos,
    giverId: giverId,
    recipientId: recipientId,
    reactions: reactions ?? this.reactions,
    commentCount: commentCount ?? this.commentCount,
    contributors: contributors,
  );

  /// Still hidden from the recipient (giver-side badge).
  bool get isPendingSurprise =>
      isSurprise && revealAt != null && DateTime.now().isBefore(revealAt!);
}
