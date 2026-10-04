// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_card.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileCard {

 String get id; String get username;@JsonKey(name: 'display_name') String? get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl;
/// Create a copy of ProfileCard
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCardCopyWith<ProfileCard> get copyWith => _$ProfileCardCopyWithImpl<ProfileCard>(this as ProfileCard, _$identity);

  /// Serializes this ProfileCard to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as ProfileCard;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileCard&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as ProfileCard;
  return Object.hash(runtimeType,_this.id,_this.username,_this.displayName,_this.avatarUrl);
}

@override
String toString() {
  final _this = this as ProfileCard;
  return 'ProfileCard(id: ${_this.id}, username: ${_this.username}, displayName: ${_this.displayName}, avatarUrl: ${_this.avatarUrl})';
}


}

/// @nodoc
abstract mixin class $ProfileCardCopyWith<$Res>  {
  factory $ProfileCardCopyWith(ProfileCard value, $Res Function(ProfileCard) _then) = _$ProfileCardCopyWithImpl;
@useResult
$Res call({
 String id, String username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class _$ProfileCardCopyWithImpl<$Res>
    implements $ProfileCardCopyWith<$Res> {
  _$ProfileCardCopyWithImpl(this._self, this._then);

  final ProfileCard _self;
  final $Res Function(ProfileCard) _then;

/// Create a copy of ProfileCard
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,}) {
  return _then(ProfileCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileCard].
extension ProfileCardPatterns on ProfileCard {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileCard value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileCard() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileCard value)  $default,){
final _that = this;
switch (_that) {
case _ProfileCard():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileCard value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileCard() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileCard() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)  $default,) {final _that = this;
switch (_that) {
case _ProfileCard():
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl)?  $default,) {final _that = this;
switch (_that) {
case _ProfileCard() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileCard implements ProfileCard {
  const _ProfileCard({required this.id, required this.username, @JsonKey(name: 'display_name') this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl});
  factory _ProfileCard.fromJson(Map<String, dynamic> json) => _$ProfileCardFromJson(json);

@override final  String id;
@override final  String username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;

/// Create a copy of ProfileCard
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCardCopyWith<_ProfileCard> get copyWith => __$ProfileCardCopyWithImpl<_ProfileCard>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileCardToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileCard&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,username,displayName,avatarUrl);
}

@override
String toString() {
    return 'ProfileCard(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl)';
}


}

/// @nodoc
abstract mixin class _$ProfileCardCopyWith<$Res> implements $ProfileCardCopyWith<$Res> {
  factory _$ProfileCardCopyWith(_ProfileCard value, $Res Function(_ProfileCard) _then) = __$ProfileCardCopyWithImpl;
@override @useResult
$Res call({
 String id, String username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl
});




}
/// @nodoc
class __$ProfileCardCopyWithImpl<$Res>
    implements _$ProfileCardCopyWith<$Res> {
  __$ProfileCardCopyWithImpl(this._self, this._then);

  final _ProfileCard _self;
  final $Res Function(_ProfileCard) _then;

/// Create a copy of ProfileCard
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,}) {
  return _then(_ProfileCard(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
