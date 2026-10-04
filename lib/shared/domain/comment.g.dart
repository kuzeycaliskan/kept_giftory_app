// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  authorId: json['author_id'] as String,
  body: json['body'] as String,
  createdAt: DateTime.parse(json['created_at'] as String),
  user: json['user'] == null
      ? null
      : ProfileCard.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'author_id': instance.authorId,
  'body': instance.body,
  'created_at': instance.createdAt.toIso8601String(),
  'user': instance.user,
};
