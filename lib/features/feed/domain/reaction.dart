import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kept/features/profile/domain/profile_card.dart';

part 'reaction.freezed.dart';
part 'reaction.g.dart';

/// Reaction kinds (G-206). Wire names match the `reaction_kind` enum; the
/// UI maps them to glyphs. Order here is the order shown in the bar.
enum ReactionKind { heart, congrats, like, ok, wow }

/// One user's reaction to a moment. [user] is null when the reactor's
/// profile is RLS-hidden from the viewer (private profile reacting to a
/// public moment) — the count still shows, the name falls back.
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
