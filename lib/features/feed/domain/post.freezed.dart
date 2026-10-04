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

 String get id;@JsonKey(name: 'author_id') String get authorId;@JsonKey(name: 'media_path') String get mediaPath;@JsonKey(name: 'created_at') DateTime get createdAt;@JsonKey(name: 'expires_at') DateTime get expiresAt; ProfileCard get author; String? get caption; List<Reaction> get reactions; int get commentCount;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Post&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.authorId, _this.authorId) || other.authorId == _this.authorId)&&(identical(other.mediaPath, _this.mediaPath) || other.mediaPath == _this.mediaPath)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.expiresAt, _this.expiresAt) || other.expiresAt == _this.expiresAt)&&(identical(other.author, _this.author) || other.author == _this.author)&&(identical(other.caption, _this.caption) || other.caption == _this.caption)&&const DeepCollectionEquality().equals(other.reactions, _this.reactions)&&(identical(other.commentCount, _this.commentCount) || other.commentCount == _this.commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Post;
  return Object.hash(runtimeType,_this.id,_this.authorId,_this.mediaPath,_this.createdAt,_this.expiresAt,_this.author,_this.caption,const DeepCollectionEquality().hash(_this.reactions),_this.commentCount);
}

@override
String toString() {
  final _this = this as Post;
  return 'Post(id: ${_this.id}, authorId: ${_this.authorId}, mediaPath: ${_this.mediaPath}, createdAt: ${_this.createdAt}, expiresAt: ${_this.expiresAt}, author: ${_this.author}, caption: ${_this.caption}, reactions: ${_this.reactions}, commentCount: ${_this.commentCount})';
}


}

/// @nodoc
abstract mixin class $PostCopyWith<$Res>  {
  factory $PostCopyWith(Post value, $Res Function(Post) _then) = _$PostCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(name: 'media_path') String mediaPath,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'expires_at') DateTime expiresAt, ProfileCard author, String? caption, List<Reaction> reactions, int commentCount
});


$ProfileCardCopyWith<$Res> get author;

}
/// @nodoc
class _$PostCopyWithImpl<$Res>
    implements $PostCopyWith<$Res> {
  _$PostCopyWithImpl(this._self, this._then);

  final Post _self;
  final $Res Function(Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? authorId = null,Object? mediaPath = null,Object? createdAt = null,Object? expiresAt = null,Object? author = null,Object? caption = freezed,Object? reactions = null,Object? commentCount = null,}) {
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
as int,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'media_path')  String mediaPath, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'expires_at')  DateTime expiresAt,  ProfileCard author,  String? caption,  List<Reaction> reactions,  int commentCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.mediaPath,_that.createdAt,_that.expiresAt,_that.author,_that.caption,_that.reactions,_that.commentCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'media_path')  String mediaPath, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'expires_at')  DateTime expiresAt,  ProfileCard author,  String? caption,  List<Reaction> reactions,  int commentCount)  $default,) {final _that = this;
switch (_that) {
case _Post():
return $default(_that.id,_that.authorId,_that.mediaPath,_that.createdAt,_that.expiresAt,_that.author,_that.caption,_that.reactions,_that.commentCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'author_id')  String authorId, @JsonKey(name: 'media_path')  String mediaPath, @JsonKey(name: 'created_at')  DateTime createdAt, @JsonKey(name: 'expires_at')  DateTime expiresAt,  ProfileCard author,  String? caption,  List<Reaction> reactions,  int commentCount)?  $default,) {final _that = this;
switch (_that) {
case _Post() when $default != null:
return $default(_that.id,_that.authorId,_that.mediaPath,_that.createdAt,_that.expiresAt,_that.author,_that.caption,_that.reactions,_that.commentCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Post extends Post {
  const _Post({required this.id, @JsonKey(name: 'author_id') required this.authorId, @JsonKey(name: 'media_path') required this.mediaPath, @JsonKey(name: 'created_at') required this.createdAt, @JsonKey(name: 'expires_at') required this.expiresAt, required this.author, this.caption,  List<Reaction> reactions = const [], this.commentCount = 0}): _reactions = reactions,super._();
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
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Post&&(identical(other.id, id) || other.id == id)&&(identical(other.authorId, authorId) || other.authorId == authorId)&&(identical(other.mediaPath, mediaPath) || other.mediaPath == mediaPath)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.author, author) || other.author == author)&&(identical(other.caption, caption) || other.caption == caption)&&const DeepCollectionEquality().equals(other.reactions, _reactions)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,authorId,mediaPath,createdAt,expiresAt,author,caption,const DeepCollectionEquality().hash(_reactions),commentCount);
}

@override
String toString() {
    return 'Post(id: $id, authorId: $authorId, mediaPath: $mediaPath, createdAt: $createdAt, expiresAt: $expiresAt, author: $author, caption: $caption, reactions: $reactions, commentCount: $commentCount)';
}


}

/// @nodoc
abstract mixin class _$PostCopyWith<$Res> implements $PostCopyWith<$Res> {
  factory _$PostCopyWith(_Post value, $Res Function(_Post) _then) = __$PostCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'author_id') String authorId,@JsonKey(name: 'media_path') String mediaPath,@JsonKey(name: 'created_at') DateTime createdAt,@JsonKey(name: 'expires_at') DateTime expiresAt, ProfileCard author, String? caption, List<Reaction> reactions, int commentCount
});


@override $ProfileCardCopyWith<$Res> get author;

}
/// @nodoc
class __$PostCopyWithImpl<$Res>
    implements _$PostCopyWith<$Res> {
  __$PostCopyWithImpl(this._self, this._then);

  final _Post _self;
  final $Res Function(_Post) _then;

/// Create a copy of Post
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? authorId = null,Object? mediaPath = null,Object? createdAt = null,Object? expiresAt = null,Object? author = null,Object? caption = freezed,Object? reactions = null,Object? commentCount = null,}) {
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
as int,
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
}
}

// dart format on
