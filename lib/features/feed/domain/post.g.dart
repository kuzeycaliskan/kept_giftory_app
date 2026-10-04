// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Post _$PostFromJson(Map<String, dynamic> json) => _Post(
  id: json['id'] as String,
  authorId: json['author_id'] as String,
  mediaPath: json['media_path'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  expiresAt: DateTime.parse(json['expires_at'] as String),
  author: ProfileCard.fromJson(json['author'] as Map<String, dynamic>),
  caption: json['caption'] as String?,
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => Reaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
  giftId: json['gift_id'] as String?,
  gift: json['gift'] == null
      ? null
      : UnboxedGift.fromJson(json['gift'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PostToJson(_Post instance) => <String, dynamic>{
  'id': instance.id,
  'author_id': instance.authorId,
  'media_path': instance.mediaPath,
  'created_at': instance.createdAt.toIso8601String(),
  'expires_at': instance.expiresAt.toIso8601String(),
  'author': instance.author,
  'caption': instance.caption,
  'reactions': instance.reactions,
  'commentCount': instance.commentCount,
  'gift_id': instance.giftId,
  'gift': instance.gift,
};

_UnboxedGift _$UnboxedGiftFromJson(Map<String, dynamic> json) => _UnboxedGift(
  id: json['id'] as String,
  item: json['item'] as String,
  giver: json['giver'] == null
      ? null
      : ProfileCard.fromJson(json['giver'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UnboxedGiftToJson(_UnboxedGift instance) =>
    <String, dynamic>{
      'id': instance.id,
      'item': instance.item,
      'giver': instance.giver,
    };
