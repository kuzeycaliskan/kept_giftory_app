// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProfileCardImpl _$$ProfileCardImplFromJson(Map<String, dynamic> json) =>
    _$ProfileCardImpl(
      id: json['id'] as String,
      username: json['username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );

Map<String, dynamic> _$$ProfileCardImplToJson(_$ProfileCardImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'display_name': instance.displayName,
      'avatar_url': instance.avatarUrl,
    };
