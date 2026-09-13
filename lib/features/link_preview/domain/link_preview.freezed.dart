// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

LinkPreview _$LinkPreviewFromJson(Map<String, dynamic> json) {
  return _LinkPreview.fromJson(json);
}

/// @nodoc
mixin _$LinkPreview {
  String get id => throw _privateConstructorUsedError;
  String? get url => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_path')
  String? get imagePath => throw _privateConstructorUsedError;
  String? get price => throw _privateConstructorUsedError;
  String? get site => throw _privateConstructorUsedError;

  /// Serializes this LinkPreview to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LinkPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LinkPreviewCopyWith<LinkPreview> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LinkPreviewCopyWith<$Res> {
  factory $LinkPreviewCopyWith(
    LinkPreview value,
    $Res Function(LinkPreview) then,
  ) = _$LinkPreviewCopyWithImpl<$Res, LinkPreview>;
  @useResult
  $Res call({
    String id,
    String? url,
    String? title,
    @JsonKey(name: 'image_path') String? imagePath,
    String? price,
    String? site,
  });
}

/// @nodoc
class _$LinkPreviewCopyWithImpl<$Res, $Val extends LinkPreview>
    implements $LinkPreviewCopyWith<$Res> {
  _$LinkPreviewCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LinkPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = freezed,
    Object? title = freezed,
    Object? imagePath = freezed,
    Object? price = freezed,
    Object? site = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            url: freezed == url
                ? _value.url
                : url // ignore: cast_nullable_to_non_nullable
                      as String?,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            imagePath: freezed == imagePath
                ? _value.imagePath
                : imagePath // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: freezed == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as String?,
            site: freezed == site
                ? _value.site
                : site // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LinkPreviewImplCopyWith<$Res>
    implements $LinkPreviewCopyWith<$Res> {
  factory _$$LinkPreviewImplCopyWith(
    _$LinkPreviewImpl value,
    $Res Function(_$LinkPreviewImpl) then,
  ) = __$$LinkPreviewImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String? url,
    String? title,
    @JsonKey(name: 'image_path') String? imagePath,
    String? price,
    String? site,
  });
}

/// @nodoc
class __$$LinkPreviewImplCopyWithImpl<$Res>
    extends _$LinkPreviewCopyWithImpl<$Res, _$LinkPreviewImpl>
    implements _$$LinkPreviewImplCopyWith<$Res> {
  __$$LinkPreviewImplCopyWithImpl(
    _$LinkPreviewImpl _value,
    $Res Function(_$LinkPreviewImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LinkPreview
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = freezed,
    Object? title = freezed,
    Object? imagePath = freezed,
    Object? price = freezed,
    Object? site = freezed,
  }) {
    return _then(
      _$LinkPreviewImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        url: freezed == url
            ? _value.url
            : url // ignore: cast_nullable_to_non_nullable
                  as String?,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        imagePath: freezed == imagePath
            ? _value.imagePath
            : imagePath // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: freezed == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as String?,
        site: freezed == site
            ? _value.site
            : site // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LinkPreviewImpl implements _LinkPreview {
  const _$LinkPreviewImpl({
    required this.id,
    this.url,
    this.title,
    @JsonKey(name: 'image_path') this.imagePath,
    this.price,
    this.site,
  });

  factory _$LinkPreviewImpl.fromJson(Map<String, dynamic> json) =>
      _$$LinkPreviewImplFromJson(json);

  @override
  final String id;
  @override
  final String? url;
  @override
  final String? title;
  @override
  @JsonKey(name: 'image_path')
  final String? imagePath;
  @override
  final String? price;
  @override
  final String? site;

  @override
  String toString() {
    return 'LinkPreview(id: $id, url: $url, title: $title, imagePath: $imagePath, price: $price, site: $site)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LinkPreviewImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.site, site) || other.site == site));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, url, title, imagePath, price, site);

  /// Create a copy of LinkPreview
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LinkPreviewImplCopyWith<_$LinkPreviewImpl> get copyWith =>
      __$$LinkPreviewImplCopyWithImpl<_$LinkPreviewImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LinkPreviewImplToJson(this);
  }
}

abstract class _LinkPreview implements LinkPreview {
  const factory _LinkPreview({
    required final String id,
    final String? url,
    final String? title,
    @JsonKey(name: 'image_path') final String? imagePath,
    final String? price,
    final String? site,
  }) = _$LinkPreviewImpl;

  factory _LinkPreview.fromJson(Map<String, dynamic> json) =
      _$LinkPreviewImpl.fromJson;

  @override
  String get id;
  @override
  String? get url;
  @override
  String? get title;
  @override
  @JsonKey(name: 'image_path')
  String? get imagePath;
  @override
  String? get price;
  @override
  String? get site;

  /// Create a copy of LinkPreview
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LinkPreviewImplCopyWith<_$LinkPreviewImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
