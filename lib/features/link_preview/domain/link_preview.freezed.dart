// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link_preview.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LinkPreview {

 String get id; String? get url; String? get title;@JsonKey(name: 'image_path') String? get imagePath; String? get price; String? get site;/// Server clock for the price refresh cadence (see [isPriceRefreshDue]).
@JsonKey(name: 'price_checked_at') DateTime? get priceCheckedAt;
/// Create a copy of LinkPreview
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkPreviewCopyWith<LinkPreview> get copyWith => _$LinkPreviewCopyWithImpl<LinkPreview>(this as LinkPreview, _$identity);

  /// Serializes this LinkPreview to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as LinkPreview;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LinkPreview&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.imagePath, _this.imagePath) || other.imagePath == _this.imagePath)&&(identical(other.price, _this.price) || other.price == _this.price)&&(identical(other.site, _this.site) || other.site == _this.site)&&(identical(other.priceCheckedAt, _this.priceCheckedAt) || other.priceCheckedAt == _this.priceCheckedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as LinkPreview;
  return Object.hash(runtimeType,_this.id,_this.url,_this.title,_this.imagePath,_this.price,_this.site,_this.priceCheckedAt);
}

@override
String toString() {
  final _this = this as LinkPreview;
  return 'LinkPreview(id: ${_this.id}, url: ${_this.url}, title: ${_this.title}, imagePath: ${_this.imagePath}, price: ${_this.price}, site: ${_this.site}, priceCheckedAt: ${_this.priceCheckedAt})';
}


}

/// @nodoc
abstract mixin class $LinkPreviewCopyWith<$Res>  {
  factory $LinkPreviewCopyWith(LinkPreview value, $Res Function(LinkPreview) _then) = _$LinkPreviewCopyWithImpl;
@useResult
$Res call({
 String id, String? url, String? title,@JsonKey(name: 'image_path') String? imagePath, String? price, String? site,@JsonKey(name: 'price_checked_at') DateTime? priceCheckedAt
});




}
/// @nodoc
class _$LinkPreviewCopyWithImpl<$Res>
    implements $LinkPreviewCopyWith<$Res> {
  _$LinkPreviewCopyWithImpl(this._self, this._then);

  final LinkPreview _self;
  final $Res Function(LinkPreview) _then;

/// Create a copy of LinkPreview
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? url = freezed,Object? title = freezed,Object? imagePath = freezed,Object? price = freezed,Object? site = freezed,Object? priceCheckedAt = freezed,}) {
  return _then(LinkPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String?,priceCheckedAt: freezed == priceCheckedAt ? _self.priceCheckedAt : priceCheckedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [LinkPreview].
extension LinkPreviewPatterns on LinkPreview {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LinkPreview value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LinkPreview() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LinkPreview value)  $default,){
final _that = this;
switch (_that) {
case _LinkPreview():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LinkPreview value)?  $default,){
final _that = this;
switch (_that) {
case _LinkPreview() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? url,  String? title, @JsonKey(name: 'image_path')  String? imagePath,  String? price,  String? site, @JsonKey(name: 'price_checked_at')  DateTime? priceCheckedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LinkPreview() when $default != null:
return $default(_that.id,_that.url,_that.title,_that.imagePath,_that.price,_that.site,_that.priceCheckedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? url,  String? title, @JsonKey(name: 'image_path')  String? imagePath,  String? price,  String? site, @JsonKey(name: 'price_checked_at')  DateTime? priceCheckedAt)  $default,) {final _that = this;
switch (_that) {
case _LinkPreview():
return $default(_that.id,_that.url,_that.title,_that.imagePath,_that.price,_that.site,_that.priceCheckedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? url,  String? title, @JsonKey(name: 'image_path')  String? imagePath,  String? price,  String? site, @JsonKey(name: 'price_checked_at')  DateTime? priceCheckedAt)?  $default,) {final _that = this;
switch (_that) {
case _LinkPreview() when $default != null:
return $default(_that.id,_that.url,_that.title,_that.imagePath,_that.price,_that.site,_that.priceCheckedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LinkPreview implements LinkPreview {
  const _LinkPreview({required this.id, this.url, this.title, @JsonKey(name: 'image_path') this.imagePath, this.price, this.site, @JsonKey(name: 'price_checked_at') this.priceCheckedAt});
  factory _LinkPreview.fromJson(Map<String, dynamic> json) => _$LinkPreviewFromJson(json);

@override final  String id;
@override final  String? url;
@override final  String? title;
@override@JsonKey(name: 'image_path') final  String? imagePath;
@override final  String? price;
@override final  String? site;
/// Server clock for the price refresh cadence (see [isPriceRefreshDue]).
@override@JsonKey(name: 'price_checked_at') final  DateTime? priceCheckedAt;

/// Create a copy of LinkPreview
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkPreviewCopyWith<_LinkPreview> get copyWith => __$LinkPreviewCopyWithImpl<_LinkPreview>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkPreviewToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LinkPreview&&(identical(other.id, id) || other.id == id)&&(identical(other.url, url) || other.url == url)&&(identical(other.title, title) || other.title == title)&&(identical(other.imagePath, imagePath) || other.imagePath == imagePath)&&(identical(other.price, price) || other.price == price)&&(identical(other.site, site) || other.site == site)&&(identical(other.priceCheckedAt, priceCheckedAt) || other.priceCheckedAt == priceCheckedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,url,title,imagePath,price,site,priceCheckedAt);
}

@override
String toString() {
    return 'LinkPreview(id: $id, url: $url, title: $title, imagePath: $imagePath, price: $price, site: $site, priceCheckedAt: $priceCheckedAt)';
}


}

/// @nodoc
abstract mixin class _$LinkPreviewCopyWith<$Res> implements $LinkPreviewCopyWith<$Res> {
  factory _$LinkPreviewCopyWith(_LinkPreview value, $Res Function(_LinkPreview) _then) = __$LinkPreviewCopyWithImpl;
@override @useResult
$Res call({
 String id, String? url, String? title,@JsonKey(name: 'image_path') String? imagePath, String? price, String? site,@JsonKey(name: 'price_checked_at') DateTime? priceCheckedAt
});




}
/// @nodoc
class __$LinkPreviewCopyWithImpl<$Res>
    implements _$LinkPreviewCopyWith<$Res> {
  __$LinkPreviewCopyWithImpl(this._self, this._then);

  final _LinkPreview _self;
  final $Res Function(_LinkPreview) _then;

/// Create a copy of LinkPreview
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? url = freezed,Object? title = freezed,Object? imagePath = freezed,Object? price = freezed,Object? site = freezed,Object? priceCheckedAt = freezed,}) {
  return _then(_LinkPreview(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,imagePath: freezed == imagePath ? _self.imagePath : imagePath // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,site: freezed == site ? _self.site : site // ignore: cast_nullable_to_non_nullable
as String?,priceCheckedAt: freezed == priceCheckedAt ? _self.priceCheckedAt : priceCheckedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
