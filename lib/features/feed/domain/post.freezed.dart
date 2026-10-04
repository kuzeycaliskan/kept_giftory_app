// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Post {

 String get id;@JsonKey(name: 'author_id') String get authorId;@JsonKey(name: 'media_path') String get mediaPath;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'expires_at') DateTime get expiresAt; ProfileCard get author; String? get caption; List<Reaction> get reactions; int get commentCount;/// G-308: the received gift this moment unboxes, if any.
@JsonKey(name: 'gift_id') String? get giftId;/// The gift as the viewer may see it — null when RLS hides it even
/// though [giftId] is set (then the tag says "unboxing", nothing more).
 UnboxedGift? get gift;
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCopyWith<Post> get copyWith => _$PostCopyWithImpl<Post>(this as Post, _$identity);

  /// Serializes this Post to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Post;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.authorId, _this.authorId) || other.authorId == _this.authorId)&&(identical(other.mediaPath, _this.mediaPath) || other.mediaPath == _this.mediaPath)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.caption, _this.caption) || other.caption == _this.caption)&&const DeepCollectionEquality().equals(other.reactions, _this.reactions)&&(identical(other.commentCount, _this.commentCount) || other.commentCount == _this.commentCount)&&(identical(other.giftId, _this.giftId) || other.giftId == _this.giftId)&&(identical(other.gift, _this.gift) || other.gift == _this.gift));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Post;
  return Object.hash(runtimeType,_this.id,_this.authorId,_this.mediaPath,_this.createdAt,_this.expiresAt,_this.author,_this.caption,const DeepCollectionEquality().hash(_this.reactions),_this.commentCount,_this.giftId,_this.gift);
}

@override
String toString() {
  final _this = this as Post;
  return 'Post(id: ${_this.id}, authorId: ${_this.authorId}, mediaPath: ${_this.mediaPath}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt}, author: ${_this.author}, caption: ${_this.caption}, reactions: ${_this.reactions}, commentCount: ${_this.commentCount}, giftId: ${_this.giftId}, gift: ${_this.gift})';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(name: 'media_path') String mediaPath,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'expires_at') DateTime expiresAt, ProfileCard author, String? caption, List<Reaction> reactions, int commentCount,@JsonKey(name: 'gift_id') String? giftId, UnboxedGift? gift
});


$ProfileCardCopyWith<$Res> get author;$UnboxedGiftCopyWith<$Res>? get gift;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = null,Object? mediaPath = null,Object? createdAt = null,Object? expiresAt = null,Object? author = null,Object? caption = freezed,Object? reactions = null,Object? commentCount = null,Object? giftId = freezed,Object? gift = freezed,}) {
  return _then(Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,mediaPath: null == mediaPath ? _self.mediaPath : mediaPath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ProfileCard,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,reactions: null == reactions ? _self.reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<Reaction>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,giftId: freezed == giftId ? _self.giftId : giftId // ignore: cast_nullable_to_non_nullable
as String?,gift: freezed == gift ? _self.gift : gift // ignore: cast_nullable_to_non_nullable
as UnboxedGift?,
  ));
}
/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCardCopyWith<$Res> get author {
  
  return $ProfileCardCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnboxedGiftCopyWith<$Res>? get gift {
    if (_self.gift == null) {
    return null;
  }

  return $UnboxedGiftCopyWith<$Res>(_self.gift!, (value) {
    return _then(_self.copyWith(gift: value));
  });
}
}


/// Adds pattern-matching-related methods to [Post].
extension PostPatterns on Post {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Post value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Post value)  $default,){
final _that = this;
switch (_that) {
case _Post():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Post value)?  $default,){
final _that = this;
switch (_that) {
case _Post() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'media_path')  String mediaPath, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'expires_at')  DateTime expiresAt,  ProfileCard author,  String? caption,  List<Reaction> reactions,  int commentCount, @JsonKey(name: 'gift_id')  String? giftId,  UnboxedGift? gift)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.mediaPath,_that.createdAt,_that.expiresAt,_that.author,_that.caption,_that.reactions,_that.commentCount,_that.giftId,_that.gift);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'media_path')  String mediaPath, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'expires_at')  DateTime expiresAt,  ProfileCard author,  String? caption,  List<Reaction> reactions,  int commentCount, @JsonKey(name: 'gift_id')  String? giftId,  UnboxedGift? gift)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.authorId,_that.mediaPath,_that.createdAt,_that.expiresAt,_that.author,_that.caption,_that.reactions,_that.commentCount,_that.giftId,_that.gift);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'media_path')  String mediaPath, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'expires_at')  DateTime expiresAt,  ProfileCard author,  String? caption,  List<Reaction> reactions,  int commentCount, @JsonKey(name: 'gift_id')  String? giftId,  UnboxedGift? gift)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.mediaPath,_that.createdAt,_that.expiresAt,_that.author,_that.caption,_that.reactions,_that.commentCount,_that.giftId,_that.gift);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Post extends Post {
  const _Post({required this.id, @JsonKey(name: 'author_id') required this.authorId, @JsonKey(name: 'media_path') required this.mediaPath, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'expires_at') required this.expiresAt, required this.author, this.caption,  List<Reaction> reactions = const [], this.commentCount = 0, @JsonKey(name: 'gift_id') this.giftId, this.gift}): _reactions = reactions,super._();
  factory _Post.fromJson(Map<String, dynamic> json) => _$PostFromJson(json);

@override final  String id;
@override@JsonKey(name: 'author_id') final  String authorId;
@override@JsonKey(name: 'media_path') final  String mediaPath;
@override@JsonKey(name: 'created_at') final  DateTime createdAt;
@override@JsonKey(name: 'expires_at') final  DateTime expiresAt;
@override final  ProfileCard author;
@override final  String? caption;
 final  List<Reaction> _reactions;
@override@JsonKey() List<Reaction> get reactions {
  if (_reactions is EqualUnmodifiableListView) return _reactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reactions);
}

@override@JsonKey() final  int commentCount;
/// G-308: the received gift this moment unboxes, if any.
@override@JsonKey(name: 'gift_id') final  String? giftId;
/// The gift as the viewer may see it — null when RLS hides it even
/// though [giftId] is set (then the tag says "unboxing", nothing more).
@override final  UnboxedGift? gift;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCopyWith<_Post> get copyWith => __$PostCopyWithImpl<_Post>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.mediaPath, mediaPath) || other.mediaPath == mediaPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other.reactions, _reactions)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.giftId, giftId) || other.giftId == giftId)&&(identical(other.gift, gift) || other.gift == gift));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,authorId,mediaPath,createdAt,expiresAt,author,caption,const DeepCollectionEquality().hash(_reactions),commentCount,giftId,gift);
}

@override
String toString() {
    return 'Post(id: $id, authorId: $authorId, mediaPath: $mediaPath, createdAt: $createdAt, expiresAt: $expiresAt, author: $author, caption: $caption, reactions: $reactions, commentCount: $commentCount, giftId: $giftId, gift: $gift)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(name: 'media_path') String mediaPath,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'expires_at') DateTime expiresAt, ProfileCard author, String? caption, List<Reaction> reactions, int commentCount,@JsonKey(name: 'gift_id') String? giftId, UnboxedGift? gift
});


@override $ProfileCardCopyWith<$Res> get author;@override $UnboxedGiftCopyWith<$Res>? get gift;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = null,Object? mediaPath = null,Object? createdAt = null,Object? expiresAt = null,Object? author = null,Object? caption = freezed,Object? reactions = null,Object? commentCount = null,Object? giftId = freezed,Object? gift = freezed,}) {
  return _then(_Post(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,authorId: null == authorId ? _self.authorId : authorId // ignore: cast_nullable_to_non_nullable
as String,mediaPath: null == mediaPath ? _self.mediaPath : mediaPath // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ProfileCard,caption: freezed == caption ? _self.caption : caption // ignore: cast_nullable_to_non_nullable
as String?,reactions: null == reactions ? _self._reactions : reactions // ignore: cast_nullable_to_non_nullable
as List<Reaction>,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,giftId: freezed == giftId ? _self.giftId : giftId // ignore: cast_nullable_to_non_nullable
as String?,gift: freezed == gift ? _self.gift : gift // ignore: cast_nullable_to_non_nullable
as UnboxedGift?,
  ));
}

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCardCopyWith<$Res> get author {
  
  return $ProfileCardCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UnboxedGiftCopyWith<$Res>? get gift {
    if (_self.gift == null) {
    return null;
  }

  return $UnboxedGiftCopyWith<$Res>(_self.gift!, (value) {
    return _then(_self.copyWith(gift: value));
  });
}
}


/// @nodoc
mixin _$UnboxedGift {

 String get id; String get item; ProfileCard? get giver;
/// Create a copy of UnboxedGift
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnboxedGiftCopyWith<UnboxedGift> get copyWith => _$UnboxedGiftCopyWithImpl<UnboxedGift>(this as UnboxedGift, _$identity);

  /// Serializes this UnboxedGift to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as UnboxedGift;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnboxedGift&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.item, _this.item) || other.item == _this.item)&&(identical(other.giver, _this.giver) || other.giver == _this.giver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as UnboxedGift;
  return Object.hash(runtimeType,_this.id,_this.item,_this.giver);
}

@override
String toString() {
  final _this = this as UnboxedGift;
  return 'UnboxedGift(id: ${_this.id}, item: ${_this.item}, giver: ${_this.giver})';
}


}

/// @nodoc
abstract mixin class $UnboxedGiftCopyWith<$Res>  {
  factory $UnboxedGiftCopyWith(UnboxedGift value, $Res Function(UnboxedGift) _then) = _$UnboxedGiftCopyWithImpl;
@useResult
$Res call({
 String id, String item, ProfileCard? giver
});


$ProfileCardCopyWith<$Res>? get giver;

}
/// @nodoc
class _$UnboxedGiftCopyWithImpl<$Res>
    implements $UnboxedGiftCopyWith<$Res> {
  _$UnboxedGiftCopyWithImpl(this._self, this._then);

  final UnboxedGift _self;
  final $Res Function(UnboxedGift) _then;

/// Create a copy of UnboxedGift
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? item = null,Object? giver = freezed,}) {
  return _then(UnboxedGift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,giver: freezed == giver ? _self.giver : giver // ignore: cast_nullable_to_non_nullable
as ProfileCard?,
  ));
}
/// Create a copy of UnboxedGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCardCopyWith<$Res>? get giver {
    if (_self.giver == null) {
    return null;
  }

  return $ProfileCardCopyWith<$Res>(_self.giver!, (value) {
    return _then(_self.copyWith(giver: value));
  });
}
}


/// Adds pattern-matching-related methods to [UnboxedGift].
extension UnboxedGiftPatterns on UnboxedGift {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UnboxedGift value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UnboxedGift() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UnboxedGift value)  $default,){
final _that = this;
switch (_that) {
case _UnboxedGift():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UnboxedGift value)?  $default,){
final _that = this;
switch (_that) {
case _UnboxedGift() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String item,  ProfileCard? giver)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UnboxedGift() when $default != null:
return $default(_that.id,_that.item,_that.giver);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String item,  ProfileCard? giver)  $default,) {final _that = this;
switch (_that) {
case _UnboxedGift():
return $default(_that.id,_that.item,_that.giver);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String item,  ProfileCard? giver)?  $default,) {final _that = this;
switch (_that) {
case _UnboxedGift() when $default != null:
return $default(_that.id,_that.item,_that.giver);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UnboxedGift implements UnboxedGift {
  const _UnboxedGift({required this.id, required this.item, this.giver});
  factory _UnboxedGift.fromJson(Map<String, dynamic> json) => _$UnboxedGiftFromJson(json);

@override final  String id;
@override final  String item;
@override final  ProfileCard? giver;

/// Create a copy of UnboxedGift
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UnboxedGiftCopyWith<_UnboxedGift> get copyWith => __$UnboxedGiftCopyWithImpl<_UnboxedGift>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UnboxedGiftToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _UnboxedGift&&(identical(other.id, id) || other.id == id)&&(identical(other.item, item) || other.item == item)&&(identical(other.giver, giver) || other.giver == giver));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,item,giver);
}

@override
String toString() {
    return 'UnboxedGift(id: $id, item: $item, giver: $giver)';
}


}

/// @nodoc
abstract mixin class _$UnboxedGiftCopyWith<$Res> implements $UnboxedGiftCopyWith<$Res> {
  factory _$UnboxedGiftCopyWith(_UnboxedGift value, $Res Function(_UnboxedGift) _then) = __$UnboxedGiftCopyWithImpl;
@override @useResult
$Res call({
 String id, String item, ProfileCard? giver
});


@override $ProfileCardCopyWith<$Res>? get giver;

}
/// @nodoc
class __$UnboxedGiftCopyWithImpl<$Res>
    implements _$UnboxedGiftCopyWith<$Res> {
  __$UnboxedGiftCopyWithImpl(this._self, this._then);

  final _UnboxedGift _self;
  final $Res Function(_UnboxedGift) _then;

/// Create a copy of UnboxedGift
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? item = null,Object? giver = freezed,}) {
  return _then(_UnboxedGift(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,item: null == item ? _self.item : item // ignore: cast_nullable_to_non_nullable
as String,giver: freezed == giver ? _self.giver : giver // ignore: cast_nullable_to_non_nullable
as ProfileCard?,
  ));
}

/// Create a copy of UnboxedGift
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCardCopyWith<$Res>? get giver {
    if (_self.giver == null) {
    return null;
  }

  return $ProfileCardCopyWith<$Res>(_self.giver!, (value) {
    return _then(_self.copyWith(giver: value));
  });
}
}

// dart format on
