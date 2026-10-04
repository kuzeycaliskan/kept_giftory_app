// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Reaction {

@JsonKey(name: 'user_id') String get userId; ReactionKind get kind; ProfileCard? get user;
/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReactionCopyWith<Reaction> get copyWith => _$ReactionCopyWithImpl<Reaction>(this as Reaction, _$identity);

  /// Serializes this Reaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Reaction;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reaction&&(identical(other.userId, _this.userId) || other.userId == _this.userId)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.user, _this.user) || other.user == _this.user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Reaction;
  return Object.hash(runtimeType,_this.userId,_this.kind,_this.user);
}

@override
String toString() {
  final _this = this as Reaction;
  return 'Reaction(userId: ${_this.userId}, kind: ${_this.kind}, user: ${_this.user})';
}


}

/// @nodoc
abstract mixin class $ReactionCopyWith<$Res>  {
  factory $ReactionCopyWith(Reaction value, $Res Function(Reaction) _then) = _$ReactionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'user_id') String userId, ReactionKind kind, ProfileCard? user
});


$ProfileCardCopyWith<$Res>? get user;

}
/// @nodoc
class _$ReactionCopyWithImpl<$Res>
    implements $ReactionCopyWith<$Res> {
  _$ReactionCopyWithImpl(this._self, this._then);

  final Reaction _self;
  final $Res Function(Reaction) _then;

/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? kind = null,Object? user = freezed,}) {
  return _then(Reaction(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReactionKind,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ProfileCard?,
  ));
}
/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCardCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileCardCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [Reaction].
extension ReactionPatterns on Reaction {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Reaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Reaction() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Reaction value)  $default,){
final _that = this;
switch (_that) {
case _Reaction():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Reaction value)?  $default,){
final _that = this;
switch (_that) {
case _Reaction() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  ReactionKind kind,  ProfileCard? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Reaction() when $default != null:
return $default(_that.userId,_that.kind,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'user_id')  String userId,  ReactionKind kind,  ProfileCard? user)  $default,) {final _that = this;
switch (_that) {
case _Reaction():
return $default(_that.userId,_that.kind,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'user_id')  String userId,  ReactionKind kind,  ProfileCard? user)?  $default,) {final _that = this;
switch (_that) {
case _Reaction() when $default != null:
return $default(_that.userId,_that.kind,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Reaction implements Reaction {
  const _Reaction({@JsonKey(name: 'user_id') required this.userId, required this.kind, this.user});
  factory _Reaction.fromJson(Map<String, dynamic> json) => _$ReactionFromJson(json);

@override@JsonKey(name: 'user_id') final  String userId;
@override final  ReactionKind kind;
@override final  ProfileCard? user;

/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReactionCopyWith<_Reaction> get copyWith => __$ReactionCopyWithImpl<_Reaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReactionToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Reaction&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,userId,kind,user);
}

@override
String toString() {
    return 'Reaction(userId: $userId, kind: $kind, user: $user)';
}


}

/// @nodoc
abstract mixin class _$ReactionCopyWith<$Res> implements $ReactionCopyWith<$Res> {
  factory _$ReactionCopyWith(_Reaction value, $Res Function(_Reaction) _then) = __$ReactionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'user_id') String userId, ReactionKind kind, ProfileCard? user
});


@override $ProfileCardCopyWith<$Res>? get user;

}
/// @nodoc
class __$ReactionCopyWithImpl<$Res>
    implements _$ReactionCopyWith<$Res> {
  __$ReactionCopyWithImpl(this._self, this._then);

  final _Reaction _self;
  final $Res Function(_Reaction) _then;

/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? kind = null,Object? user = freezed,}) {
  return _then(_Reaction(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ReactionKind,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as ProfileCard?,
  ));
}

/// Create a copy of Reaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCardCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileCardCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}

// dart format on
