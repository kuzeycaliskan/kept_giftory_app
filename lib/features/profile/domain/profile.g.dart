// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileImpl _$$ProfileImplFromJson(
  Map<String, dynamic> json,
) => _$ProfileImpl(
  id: json['id'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  birthday: json['birthday'] == null
      ? null
      : DateTime.parse(json['birthday'] as String),
  gender: json['gender'] as String?,
  occupation: json['occupation'] as String?,
  bio: json['bio'] as String?,
  profileVisibility:
      $enumDecodeNullable(_$VisibilityEnumMap, json['profile_visibility']) ??
      Visibility.friends,
  wishlistVisibility:
      $enumDecodeNullable(_$VisibilityEnumMap, json['wishlist_visibility']) ??
      Visibility.friends,
  giftHistoryVisibility:
      $enumDecodeNullable(
        _$VisibilityEnumMap,
        json['gift_history_visibility'],
      ) ??
      Visibility.friends,
);

Map<String, dynamic> _$$ProfileImplToJson(_$ProfileImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
      'birthday': instance.birthday?.toIso8601String(),
      'gender': instance.gender,
      'occupation': instance.occupation,
      'bio': instance.bio,
      'profile_visibility': _$VisibilityEnumMap[instance.profileVisibility]!,
      'wishlist_visibility': _$VisibilityEnumMap[instance.wishlistVisibility]!,
      'gift_history_visibility':
          _$VisibilityEnumMap[instance.giftHistoryVisibility]!,
    };

const _$VisibilityEnumMap = {
  Visibility.public: 'public',
  Visibility.friends: 'friends',
  Visibility.private: 'private',
};
