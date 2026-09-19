// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReactionImpl _$$ReactionImplFromJson(Map<String, dynamic> json) =>
    _$ReactionImpl(
      userId: json['user_id'] as String,
      kind: $enumDecode(_$ReactionKindEnumMap, json['kind']),
      user: json['user'] == null
          ? null
          : ProfileCard.fromJson(json['user'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ReactionImplToJson(_$ReactionImpl instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'kind': _$ReactionKindEnumMap[instance.kind]!,
      'user': instance.user,
    };

const _$ReactionKindEnumMap = {
  ReactionKind.heart: 'heart',
  ReactionKind.congrats: 'congrats',
  ReactionKind.like: 'like',
  ReactionKind.ok: 'ok',
  ReactionKind.wow: 'wow',
};
