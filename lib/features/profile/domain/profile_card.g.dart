// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProfileCard _$ProfileCardFromJson(Map<String, dynamic> json) => _ProfileCard(
  id: json['id'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$ProfileCardToJson(_ProfileCard instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
    };
