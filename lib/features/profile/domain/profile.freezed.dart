// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get id; String get username;@JsonKey(name: 'display_name') String? get displayName;@JsonKey(name: 'avatar_url') String? get avatarUrl; DateTime? get birthday; String? get gender; String? get occupation; String? get bio;@JsonKey(name: 'profile_visibility') Visibility get profileVisibility;@JsonKey(name: 'wishlist_visibility') Visibility get wishlistVisibility;@JsonKey(name: 'gift_history_visibility') Visibility get giftHistoryVisibility;@JsonKey(name: 'invite_code') String? get inviteCode;@JsonKey(name: 'birthday_reminders_enabled') bool get birthdayRemindersEnabled;@JsonKey(name: 'social_notifications_enabled') bool get socialNotificationsEnabled;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  final _this = this as Profile;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.username, _this.username) || other.username == _this.username)&&(identical(other.displayName, _this.displayName) || other.displayName == _this.displayName)&&(identical(other.avatarUrl, _this.avatarUrl) || other.avatarUrl == _this.avatarUrl)&&(identical(other.birthday, _this.birthday) || other.birthday == _this.birthday)&&(identical(other.gender, _this.gender) || other.gender == _this.gender)&&(identical(other.occupation, _this.occupation) || other.occupation == _this.occupation)&&(identical(other.bio, _this.bio) || other.bio == _this.bio)&&(identical(other.profileVisibility, _this.profileVisibility) || other.profileVisibility == _this.profileVisibility)&&(identical(other.wishlistVisibility, _this.wishlistVisibility) || other.wishlistVisibility == _this.wishlistVisibility)&&(identical(other.giftHistoryVisibility, _this.giftHistoryVisibility) || other.giftHistoryVisibility == _this.giftHistoryVisibility)&&(identical(other.inviteCode, _this.inviteCode) || other.inviteCode == _this.inviteCode)&&(identical(other.birthdayRemindersEnabled, _this.birthdayRemindersEnabled) || other.birthdayRemindersEnabled == _this.birthdayRemindersEnabled)&&(identical(other.socialNotificationsEnabled, _this.socialNotificationsEnabled) || other.socialNotificationsEnabled == _this.socialNotificationsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
  final _this = this as Profile;
  return Object.hash(runtimeType,_this.id,_this.username,_this.displayName,_this.avatarUrl,_this.birthday,_this.gender,_this.occupation,_this.bio,_this.profileVisibility,_this.wishlistVisibility,_this.giftHistoryVisibility,_this.inviteCode,_this.birthdayRemindersEnabled,_this.socialNotificationsEnabled);
}

@override
String toString() {
  final _this = this as Profile;
  return 'Profile(id: ${_this.id}, username: ${_this.username}, displayName: ${_this.displayName}, avatarUrl: ${_this.avatarUrl}, birthday: ${_this.birthday}, gender: ${_this.gender}, occupation: ${_this.occupation}, bio: ${_this.bio}, profileVisibility: ${_this.profileVisibility}, wishlistVisibility: ${_this.wishlistVisibility}, giftHistoryVisibility: ${_this.giftHistoryVisibility}, inviteCode: ${_this.inviteCode}, birthdayRemindersEnabled: ${_this.birthdayRemindersEnabled}, socialNotificationsEnabled: ${_this.socialNotificationsEnabled})';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl, DateTime? birthday, String? gender, String? occupation, String? bio,@JsonKey(name: 'profile_visibility') Visibility profileVisibility,@JsonKey(name: 'wishlist_visibility') Visibility wishlistVisibility,@JsonKey(name: 'gift_history_visibility') Visibility giftHistoryVisibility,@JsonKey(name: 'invite_code') String? inviteCode,@JsonKey(name: 'birthday_reminders_enabled') bool birthdayRemindersEnabled,@JsonKey(name: 'social_notifications_enabled') bool socialNotificationsEnabled
});




}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? birthday = freezed,Object? gender = freezed,Object? occupation = freezed,Object? bio = freezed,Object? profileVisibility = null,Object? wishlistVisibility = null,Object? giftHistoryVisibility = null,Object? inviteCode = freezed,Object? birthdayRemindersEnabled = null,Object? socialNotificationsEnabled = null,}) {
  return _then(Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profileVisibility: null == profileVisibility ? _self.profileVisibility : profileVisibility // ignore: cast_nullable_to_non_nullable
as Visibility,wishlistVisibility: null == wishlistVisibility ? _self.wishlistVisibility : wishlistVisibility // ignore: cast_nullable_to_non_nullable
as Visibility,giftHistoryVisibility: null == giftHistoryVisibility ? _self.giftHistoryVisibility : giftHistoryVisibility // ignore: cast_nullable_to_non_nullable
as Visibility,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,birthdayRemindersEnabled: null == birthdayRemindersEnabled ? _self.birthdayRemindersEnabled : birthdayRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,socialNotificationsEnabled: null == socialNotificationsEnabled ? _self.socialNotificationsEnabled : socialNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  DateTime? birthday,  String? gender,  String? occupation,  String? bio, @JsonKey(name: 'profile_visibility')  Visibility profileVisibility, @JsonKey(name: 'wishlist_visibility')  Visibility wishlistVisibility, @JsonKey(name: 'gift_history_visibility')  Visibility giftHistoryVisibility, @JsonKey(name: 'invite_code')  String? inviteCode, @JsonKey(name: 'birthday_reminders_enabled')  bool birthdayRemindersEnabled, @JsonKey(name: 'social_notifications_enabled')  bool socialNotificationsEnabled)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl,_that.birthday,_that.gender,_that.occupation,_that.bio,_that.profileVisibility,_that.wishlistVisibility,_that.giftHistoryVisibility,_that.inviteCode,_that.birthdayRemindersEnabled,_that.socialNotificationsEnabled);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  DateTime? birthday,  String? gender,  String? occupation,  String? bio, @JsonKey(name: 'profile_visibility')  Visibility profileVisibility, @JsonKey(name: 'wishlist_visibility')  Visibility wishlistVisibility, @JsonKey(name: 'gift_history_visibility')  Visibility giftHistoryVisibility, @JsonKey(name: 'invite_code')  String? inviteCode, @JsonKey(name: 'birthday_reminders_enabled')  bool birthdayRemindersEnabled, @JsonKey(name: 'social_notifications_enabled')  bool socialNotificationsEnabled)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl,_that.birthday,_that.gender,_that.occupation,_that.bio,_that.profileVisibility,_that.wishlistVisibility,_that.giftHistoryVisibility,_that.inviteCode,_that.birthdayRemindersEnabled,_that.socialNotificationsEnabled);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username, @JsonKey(name: 'display_name')  String? displayName, @JsonKey(name: 'avatar_url')  String? avatarUrl,  DateTime? birthday,  String? gender,  String? occupation,  String? bio, @JsonKey(name: 'profile_visibility')  Visibility profileVisibility, @JsonKey(name: 'wishlist_visibility')  Visibility wishlistVisibility, @JsonKey(name: 'gift_history_visibility')  Visibility giftHistoryVisibility, @JsonKey(name: 'invite_code')  String? inviteCode, @JsonKey(name: 'birthday_reminders_enabled')  bool birthdayRemindersEnabled, @JsonKey(name: 'social_notifications_enabled')  bool socialNotificationsEnabled)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl,_that.birthday,_that.gender,_that.occupation,_that.bio,_that.profileVisibility,_that.wishlistVisibility,_that.giftHistoryVisibility,_that.inviteCode,_that.birthdayRemindersEnabled,_that.socialNotificationsEnabled);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile implements Profile {
  const _Profile({required this.id, required this.username, @JsonKey(name: 'display_name') this.displayName, @JsonKey(name: 'avatar_url') this.avatarUrl, this.birthday, this.gender, this.occupation, this.bio, @JsonKey(name: 'profile_visibility') this.profileVisibility = Visibility.friends, @JsonKey(name: 'wishlist_visibility') this.wishlistVisibility = Visibility.friends, @JsonKey(name: 'gift_history_visibility') this.giftHistoryVisibility = Visibility.friends, @JsonKey(name: 'invite_code') this.inviteCode, @JsonKey(name: 'birthday_reminders_enabled') this.birthdayRemindersEnabled = true, @JsonKey(name: 'social_notifications_enabled') this.socialNotificationsEnabled = true});
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String username;
@override@JsonKey(name: 'display_name') final  String? displayName;
@override@JsonKey(name: 'avatar_url') final  String? avatarUrl;
@override final  DateTime? birthday;
@override final  String? gender;
@override final  String? occupation;
@override final  String? bio;
@override@JsonKey(name: 'profile_visibility') final  Visibility profileVisibility;
@override@JsonKey(name: 'wishlist_visibility') final  Visibility wishlistVisibility;
@override@JsonKey(name: 'gift_history_visibility') final  Visibility giftHistoryVisibility;
@override@JsonKey(name: 'invite_code') final  String? inviteCode;
@override@JsonKey(name: 'birthday_reminders_enabled') final  bool birthdayRemindersEnabled;
@override@JsonKey(name: 'social_notifications_enabled') final  bool socialNotificationsEnabled;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.birthday, birthday) || other.birthday == birthday)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.profileVisibility, profileVisibility) || other.profileVisibility == profileVisibility)&&(identical(other.wishlistVisibility, wishlistVisibility) || other.wishlistVisibility == wishlistVisibility)&&(identical(other.giftHistoryVisibility, giftHistoryVisibility) || other.giftHistoryVisibility == giftHistoryVisibility)&&(identical(other.inviteCode, inviteCode) || other.inviteCode == inviteCode)&&(identical(other.birthdayRemindersEnabled, birthdayRemindersEnabled) || other.birthdayRemindersEnabled == birthdayRemindersEnabled)&&(identical(other.socialNotificationsEnabled, socialNotificationsEnabled) || other.socialNotificationsEnabled == socialNotificationsEnabled));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode {
    return Object.hash(runtimeType,id,username,displayName,avatarUrl,birthday,gender,occupation,bio,profileVisibility,wishlistVisibility,giftHistoryVisibility,inviteCode,birthdayRemindersEnabled,socialNotificationsEnabled);
}

@override
String toString() {
    return 'Profile(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, birthday: $birthday, gender: $gender, occupation: $occupation, bio: $bio, profileVisibility: $profileVisibility, wishlistVisibility: $wishlistVisibility, giftHistoryVisibility: $giftHistoryVisibility, inviteCode: $inviteCode, birthdayRemindersEnabled: $birthdayRemindersEnabled, socialNotificationsEnabled: $socialNotificationsEnabled)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String username,@JsonKey(name: 'display_name') String? displayName,@JsonKey(name: 'avatar_url') String? avatarUrl, DateTime? birthday, String? gender, String? occupation, String? bio,@JsonKey(name: 'profile_visibility') Visibility profileVisibility,@JsonKey(name: 'wishlist_visibility') Visibility wishlistVisibility,@JsonKey(name: 'gift_history_visibility') Visibility giftHistoryVisibility,@JsonKey(name: 'invite_code') String? inviteCode,@JsonKey(name: 'birthday_reminders_enabled') bool birthdayRemindersEnabled,@JsonKey(name: 'social_notifications_enabled') bool socialNotificationsEnabled
});




}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? birthday = freezed,Object? gender = freezed,Object? occupation = freezed,Object? bio = freezed,Object? profileVisibility = null,Object? wishlistVisibility = null,Object? giftHistoryVisibility = null,Object? inviteCode = freezed,Object? birthdayRemindersEnabled = null,Object? socialNotificationsEnabled = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,birthday: freezed == birthday ? _self.birthday : birthday // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,profileVisibility: null == profileVisibility ? _self.profileVisibility : profileVisibility // ignore: cast_nullable_to_non_nullable
as Visibility,wishlistVisibility: null == wishlistVisibility ? _self.wishlistVisibility : wishlistVisibility // ignore: cast_nullable_to_non_nullable
as Visibility,giftHistoryVisibility: null == giftHistoryVisibility ? _self.giftHistoryVisibility : giftHistoryVisibility // ignore: cast_nullable_to_non_nullable
as Visibility,inviteCode: freezed == inviteCode ? _self.inviteCode : inviteCode // ignore: cast_nullable_to_non_nullable
as String?,birthdayRemindersEnabled: null == birthdayRemindersEnabled ? _self.birthdayRemindersEnabled : birthdayRemindersEnabled // ignore: cast_nullable_to_non_nullable
as bool,socialNotificationsEnabled: null == socialNotificationsEnabled ? _self.socialNotificationsEnabled : socialNotificationsEnabled // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
