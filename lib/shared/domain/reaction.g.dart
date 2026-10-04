// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Reaction _$ReactionFromJson(Map<String, dynamic> json) => _Reaction(
  userId: json['user_id'] as String,
  kind: $enumDecode(_$ReactionKindEnumMap, json['kind']),
  user: json['user'] == null
      ? null
      : ProfileCard.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ReactionToJson(_Reaction instance) => <String, dynamic>{
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
