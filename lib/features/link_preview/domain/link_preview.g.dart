// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'link_preview.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LinkPreview _$LinkPreviewFromJson(Map<String, dynamic> json) => _LinkPreview(
  id: json['id'] as String,
  url: json['url'] as String?,
  title: json['title'] as String?,
  imagePath: json['image_path'] as String?,
  price: json['price'] as String?,
  site: json['site'] as String?,
  priceCheckedAt: json['price_checked_at'] == null
      ? null
      : DateTime.parse(json['price_checked_at'] as String),
);

Map<String, dynamic> _$LinkPreviewToJson(_LinkPreview instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'image_path': instance.imagePath,
      'price': instance.price,
      'site': instance.site,
      'price_checked_at': instance.priceCheckedAt?.toIso8601String(),
    };
