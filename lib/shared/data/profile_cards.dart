import 'package:kept/features/profile/domain/profile_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Batch discovery cards via the `profile_cards` definer RPC (block-aware,
/// visible regardless of profile privacy — the rule for reactors and
/// commenters). Empty input → no round trip.
Future<Map<String, ProfileCard>> fetchProfileCards(
  SupabaseClient client,
  Iterable<String> ids,
) async {
  final unique = ids.toSet().toList();
  if (unique.isEmpty) return const {};
  final rows = await client.rpc<List<dynamic>>(
    'profile_cards',
    params: {'p_ids': unique},
  );
  return {
    for (final raw in rows.cast<Map<String, dynamic>>())
      raw['id']! as String: ProfileCard.fromJson(raw),
  };
}
