import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

part 'reaction.freezed.dart';
part 'reaction.g.dart';

/// Reaction kinds (G-206), shared by moments and gifts. Wire names match
/// the `reaction_kind` enum; the UI maps them to glyphs. Declaration order
/// is the order shown in the bar.
enum ReactionKind { heart, congrats, like, ok, wow }

/// One user's reaction to a moment or a gift. The live path resolves [user]
/// through a definer RPC, so the reactor is named even with a hidden
/// profile (product rule); null is a defensive fallback only.
@freezed
class Reaction with _$Reaction {
  const factory Reaction({
    @JsonKey(name: 'user_id') required String userId,
    required ReactionKind kind,
    ProfileCard? user,
  }) = _Reaction;

  factory Reaction.fromJson(Map<String, dynamic> json) =>
      _$ReactionFromJson(json);
}
