import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

enum Visibility {
  @JsonValue('public')
  public,
  @JsonValue('friends')
  friends,
  @JsonValue('private')
  private,
}

/// Domain model for a user profile (maps `public.profiles`).
@freezed
class Profile with _$Profile {
  const factory Profile({
    required String id,
    required String username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    DateTime? birthday,
    String? gender,
    String? occupation,
    String? bio,
    @JsonKey(name: 'profile_visibility')
    @Default(Visibility.friends)
    Visibility profileVisibility,
    @JsonKey(name: 'wishlist_visibility')
    @Default(Visibility.friends)
    Visibility wishlistVisibility,
    @JsonKey(name: 'gift_history_visibility')
    @Default(Visibility.friends)
    Visibility giftHistoryVisibility,
    @JsonKey(name: 'invite_code') String? inviteCode,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
}
