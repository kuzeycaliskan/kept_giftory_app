import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_card.freezed.dart';
part 'profile_card.g.dart';

/// Minimal, always-discoverable slice of a profile (G-32): what a stranger
/// may see about a friends-only account — avatar, username, display name.
/// Maps the `search_profiles` / `profile_card` RPC rows.
@freezed
class ProfileCard with _$ProfileCard {
  const factory ProfileCard({
    required String id,
    required String username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
  }) = _ProfileCard;

  factory ProfileCard.fromJson(Map<String, dynamic> json) =>
      _$ProfileCardFromJson(json);
}
