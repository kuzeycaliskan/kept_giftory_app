import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/shared/data/profile_cards.dart';
import 'package:kept/shared/domain/reaction.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Column list every gift read shares (photos + link preview embedded).
/// `counterpartKey` picks which embedded profile becomes the counterpart.
const String giftEmbeds =
    ' preview:link_previews(id, url, title, image_path, price, site, '
    'price_checked_at), '
    'photos:gift_photos(id, gift_id, uploader_id, media_path, created_at), '
    'reactions:gift_reactions(user_id, kind), '
    'comments:gift_comments(count)';

/// Maps a `gifts` row (with embeds) to the UI entry. Shared by the gifts
/// repository and the Home feed so one mapping rule exists.
GiftEntry giftEntryFromRow(
  Map<String, dynamic> row, {
  required String counterpartKey,
}) {
  final counterpart = row[counterpartKey] as Map<String, dynamic>?;
  return GiftEntry(
    id: row['id']! as String,
    item: row['item']! as String,
    note: row['note'] as String?,
    giftDate: DateTime.parse(row['gift_date']! as String),
    isSurprise: row['is_surprise']! as bool,
    revealAt: row['reveal_at'] == null
        ? null
        : DateTime.parse(row['reveal_at']! as String),
    counterpartId: counterpart?['id'] as String?,
    counterpartLabel: counterpart == null
        ? null
        : (counterpart['display_name'] as String?) ??
              (counterpart['username'] as String?),
    preview: row['preview'] == null
        ? null
        : LinkPreview.fromJson(row['preview'] as Map<String, dynamic>),
    giverRelation: row['giver_relation'] == null
        ? null
        : GiftRelation.values.byName(row['giver_relation'] as String),
    photos: giftPhotosFromRows(row['photos']),
    giverId: row['giver_id'] as String?,
    recipientId: row['recipient_id'] as String?,
    commentCount: embeddedCount(row['comments']),
    reactions: [
      for (final r
          in (row['reactions'] as List<dynamic>? ?? const [])
              .cast<Map<String, dynamic>>())
        Reaction(
          userId: r['user_id']! as String,
          kind: ReactionKind.values.byName(r['kind']! as String),
        ),
    ],
  );
}

/// Fills in reactor identities (product rule: whoever reacted is named,
/// whatever their profile visibility). One round trip for a whole list.
Future<List<GiftEntry>> resolveReactionCards(
  SupabaseClient client,
  List<GiftEntry> gifts,
) async {
  final cards = await fetchProfileCards(client, [
    for (final g in gifts)
      for (final r in g.reactions) r.userId,
  ]);
  if (cards.isEmpty) return gifts;
  return [
    for (final g in gifts)
      g.copyWith(
        reactions: [
          for (final r in g.reactions) r.copyWith(user: cards[r.userId]),
        ],
      ),
  ];
}

/// PostgREST `relation(count)` embeds come back as `[{"count": n}]`.
int embeddedCount(Object? raw) {
  final rows = raw as List<dynamic>? ?? const [];
  if (rows.isEmpty) return 0;
  return (rows.first as Map<String, dynamic>)['count'] as int? ?? 0;
}

List<GiftPhoto> giftPhotosFromRows(Object? raw) {
  final rows = (raw as List<dynamic>? ?? const []).cast<Map<String, dynamic>>();
  return [
    for (final r in rows)
      GiftPhoto(
        id: r['id']! as String,
        giftId: r['gift_id']! as String,
        uploaderId: r['uploader_id']! as String,
        mediaPath: r['media_path']! as String,
        createdAt: DateTime.parse(r['created_at']! as String),
      ),
  ]..sort((a, b) => a.createdAt.compareTo(b.createdAt));
}
