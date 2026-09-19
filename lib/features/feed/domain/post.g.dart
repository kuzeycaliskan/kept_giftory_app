// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PostImpl _$$PostImplFromJson(Map<String, dynamic> json) => _$PostImpl(
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
);

Map<String, dynamic> _$$PostImplToJson(_$PostImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'author_id': instance.authorId,
      'media_path': instance.mediaPath,
      'created_at': instance.createdAt.toIso8601String(),
      'expires_at': instance.expiresAt.toIso8601String(),
      'author': instance.author,
      'caption': instance.caption,
      'reactions': instance.reactions,
      'commentCount': instance.commentCount,
    };
