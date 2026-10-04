// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wishlist_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WishlistItem {

 String get id;@JsonKey(name: 'owner_id') String get ownerId; String get title; String? get note; String? get url;@JsonKey(name: 'image_url') String? get imageUrl; int get priority;@JsonKey(name: 'created_at') DateTime? get createdAt;@JsonKey(name: 'link_preview_id') String? get linkPreviewId;/// Joined `link_previews` row (G-211); null when none attached.
 LinkPreview? get preview;
/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WishlistItemCopyWith<WishlistItem> get copyWith => _$WishlistItemCopyWithImpl<WishlistItem>(this as WishlistItem, _$identity);

  /// Serializes this WishlistItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as WishlistItem;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WishlistItem&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.ownerId, _this.ownerId) || other.ownerId == _this.ownerId)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.imageUrl, _this.imageUrl) || other.imageUrl == _this.imageUrl)&&(identical(other.priority, _this.priority) || other.priority == _this.priority)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.linkPreviewId, _this.linkPreviewId) || other.linkPreviewId == _this.linkPreviewId)&&(identical(other.preview, _this.preview) || other.preview == _this.preview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as WishlistItem;
  return Object.hash(runtimeType,_this.id,_this.ownerId,_this.title,_this.note,_this.url,_this.imageUrl,_this.priority,_this.createdAt,_this.linkPreviewId,_this.preview);
}

@override
String toString() {
  final _this = this as WishlistItem;
  return 'WishlistItem(id: ${_this.id}, ownerId: ${_this.ownerId}, title: ${_this.title}, note: ${_this.note}, url: ${_this.url}, imageUrl: ${_this.imageUrl}, priority: ${_this.priority}, createdAt: ${_this.createdAt}, linkPreviewId: ${_this.linkPreviewId}, preview: ${_this.preview})';
}


}

/// @nodoc
abstract mixin class $WishlistItemCopyWith<$Res>  {
  factory $WishlistItemCopyWith(WishlistItem value, $Res Function(WishlistItem) _then) = _$WishlistItemCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'owner_id') String ownerId, String title, String? note, String? url,@JsonKey(name: 'image_url') String? imageUrl, int priority,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'link_preview_id') String? linkPreviewId, LinkPreview? preview
});


$LinkPreviewCopyWith<$Res>? get preview;

}
/// @nodoc
class _$WishlistItemCopyWithImpl<$Res>
    implements $WishlistItemCopyWith<$Res> {
  _$WishlistItemCopyWithImpl(this._self, this._then);

  final WishlistItem _self;
  final $Res Function(WishlistItem) _then;

/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? ownerId = null,Object? title = null,Object? note = freezed,Object? url = freezed,Object? imageUrl = freezed,Object? priority = null,Object? createdAt = freezed,Object? linkPreviewId = freezed,Object? preview = freezed,}) {
  return _then(WishlistItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,linkPreviewId: freezed == linkPreviewId ? _self.linkPreviewId : linkPreviewId // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as LinkPreview?,
  ));
}
/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkPreviewCopyWith<$Res>? get preview {
    if (_self.preview == null) {
    return null;
  }

  return $LinkPreviewCopyWith<$Res>(_self.preview!, (value) {
    return _then(_self.copyWith(preview: value));
  });
}
}


/// Adds pattern-matching-related methods to [WishlistItem].
extension WishlistItemPatterns on WishlistItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WishlistItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WishlistItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WishlistItem value)  $default,){
final _that = this;
switch (_that) {
case _WishlistItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WishlistItem value)?  $default,){
final _that = this;
switch (_that) {
case _WishlistItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_id')  String ownerId,  String title,  String? note,  String? url, @JsonKey(name: 'image_url')  String? imageUrl,  int priority, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'link_preview_id')  String? linkPreviewId,  LinkPreview? preview)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WishlistItem() when $default != null:
return $default(_that.id,_that.ownerId,_that.title,_that.note,_that.url,_that.imageUrl,_that.priority,_that.createdAt,_that.linkPreviewId,_that.preview);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'owner_id')  String ownerId,  String title,  String? note,  String? url, @JsonKey(name: 'image_url')  String? imageUrl,  int priority, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'link_preview_id')  String? linkPreviewId,  LinkPreview? preview)  $default,) {final _that = this;
switch (_that) {
case _WishlistItem():
return $default(_that.id,_that.ownerId,_that.title,_that.note,_that.url,_that.imageUrl,_that.priority,_that.createdAt,_that.linkPreviewId,_that.preview);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'owner_id')  String ownerId,  String title,  String? note,  String? url, @JsonKey(name: 'image_url')  String? imageUrl,  int priority, @JsonKey(name: 'created_at')  DateTime? createdAt, @JsonKey(name: 'link_preview_id')  String? linkPreviewId,  LinkPreview? preview)?  $default,) {final _that = this;
switch (_that) {
case _WishlistItem() when $default != null:
return $default(_that.id,_that.ownerId,_that.title,_that.note,_that.url,_that.imageUrl,_that.priority,_that.createdAt,_that.linkPreviewId,_that.preview);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WishlistItem implements WishlistItem {
  const _WishlistItem({required this.id, @JsonKey(name: 'owner_id') required this.ownerId, required this.title, this.note, this.url, @JsonKey(name: 'image_url') this.imageUrl, this.priority = 0, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'link_preview_id') this.linkPreviewId, this.preview});
  factory _WishlistItem.fromJson(Map<String, dynamic> json) => _$WishlistItemFromJson(json);

@override final  String id;
@override@JsonKey(name: 'owner_id') final  String ownerId;
@override final  String title;
@override final  String? note;
@override final  String? url;
@override@JsonKey(name: 'image_url') final  String? imageUrl;
@override@JsonKey() final  int priority;
@override@JsonKey(name: 'created_at') final  DateTime? createdAt;
@override@JsonKey(name: 'link_preview_id') final  String? linkPreviewId;
/// Joined `link_previews` row (G-211); null when none attached.
@override final  LinkPreview? preview;

/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WishlistItemCopyWith<_WishlistItem> get copyWith => __$WishlistItemCopyWithImpl<_WishlistItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WishlistItemToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WishlistItem&&(identical(other.id, id) || other.id == id)&&(identical(other.ownerId, ownerId) || other.ownerId == ownerId)&&(identical(other.title, title) || other.title == title)&&(identical(other.note, note) || other.note == note)&&(identical(other.url, url) || other.url == url)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.linkPreviewId, linkPreviewId) || other.linkPreviewId == linkPreviewId)&&(identical(other.preview, preview) || other.preview == preview));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,ownerId,title,note,url,imageUrl,priority,createdAt,linkPreviewId,preview);
}

@override
String toString() {
    return 'WishlistItem(id: $id, ownerId: $ownerId, title: $title, note: $note, url: $url, imageUrl: $imageUrl, priority: $priority, createdAt: $createdAt, linkPreviewId: $linkPreviewId, preview: $preview)';
}


}

/// @nodoc
abstract mixin class _$WishlistItemCopyWith<$Res> implements $WishlistItemCopyWith<$Res> {
  factory _$WishlistItemCopyWith(_WishlistItem value, $Res Function(_WishlistItem) _then) = __$WishlistItemCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'owner_id') String ownerId, String title, String? note, String? url,@JsonKey(name: 'image_url') String? imageUrl, int priority,@JsonKey(name: 'created_at') DateTime? createdAt,@JsonKey(name: 'link_preview_id') String? linkPreviewId, LinkPreview? preview
});


@override $LinkPreviewCopyWith<$Res>? get preview;

}
/// @nodoc
class __$WishlistItemCopyWithImpl<$Res>
    implements _$WishlistItemCopyWith<$Res> {
  __$WishlistItemCopyWithImpl(this._self, this._then);

  final _WishlistItem _self;
  final $Res Function(_WishlistItem) _then;

/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? ownerId = null,Object? title = null,Object? note = freezed,Object? url = freezed,Object? imageUrl = freezed,Object? priority = null,Object? createdAt = freezed,Object? linkPreviewId = freezed,Object? preview = freezed,}) {
  return _then(_WishlistItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,ownerId: null == ownerId ? _self.ownerId : ownerId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,priority: null == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,linkPreviewId: freezed == linkPreviewId ? _self.linkPreviewId : linkPreviewId // ignore: cast_nullable_to_non_nullable
as String?,preview: freezed == preview ? _self.preview : preview // ignore: cast_nullable_to_non_nullable
as LinkPreview?,
  ));
}

/// Create a copy of WishlistItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LinkPreviewCopyWith<$Res>? get preview {
    if (_self.preview == null) {
    return null;
  }

  return $LinkPreviewCopyWith<$Res>(_self.preview!, (value) {
    return _then(_self.copyWith(preview: value));
  });
}
}

// dart format on
