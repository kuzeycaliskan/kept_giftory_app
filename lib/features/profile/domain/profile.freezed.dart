// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Profile _$ProfileFromJson(Map<String, dynamic> json) {
  return _Profile.fromJson(json);
}

/// @nodoc
mixin _$Profile {
  String get id => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'display_name')
  String? get displayName => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  DateTime? get birthday => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get occupation => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  @JsonKey(name: 'profile_visibility')
  Visibility get profileVisibility => throw _privateConstructorUsedError;
  @JsonKey(name: 'wishlist_visibility')
  Visibility get wishlistVisibility => throw _privateConstructorUsedError;
  @JsonKey(name: 'gift_history_visibility')
  Visibility get giftHistoryVisibility => throw _privateConstructorUsedError;

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileCopyWith<Profile> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileCopyWith<$Res> {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) then) =
      _$ProfileCopyWithImpl<$Res, Profile>;
  @useResult
  $Res call({
    String id,
    String username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    DateTime? birthday,
    String? gender,
    String? occupation,
    String? bio,
    @JsonKey(name: 'profile_visibility') Visibility profileVisibility,
    @JsonKey(name: 'wishlist_visibility') Visibility wishlistVisibility,
    @JsonKey(name: 'gift_history_visibility') Visibility giftHistoryVisibility,
  });
}

/// @nodoc
class _$ProfileCopyWithImpl<$Res, $Val extends Profile>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? birthday = freezed,
    Object? gender = freezed,
    Object? occupation = freezed,
    Object? bio = freezed,
    Object? profileVisibility = null,
    Object? wishlistVisibility = null,
    Object? giftHistoryVisibility = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            username: null == username
                ? _value.username
                : username // ignore: cast_nullable_to_non_nullable
                      as String,
            displayName: freezed == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String?,
            avatarUrl: freezed == avatarUrl
                ? _value.avatarUrl
                : avatarUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            birthday: freezed == birthday
                ? _value.birthday
                : birthday // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            gender: freezed == gender
                ? _value.gender
                : gender // ignore: cast_nullable_to_non_nullable
                      as String?,
            occupation: freezed == occupation
                ? _value.occupation
                : occupation // ignore: cast_nullable_to_non_nullable
                      as String?,
            bio: freezed == bio
                ? _value.bio
                : bio // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileVisibility: null == profileVisibility
                ? _value.profileVisibility
                : profileVisibility // ignore: cast_nullable_to_non_nullable
                      as Visibility,
            wishlistVisibility: null == wishlistVisibility
                ? _value.wishlistVisibility
                : wishlistVisibility // ignore: cast_nullable_to_non_nullable
                      as Visibility,
            giftHistoryVisibility: null == giftHistoryVisibility
                ? _value.giftHistoryVisibility
                : giftHistoryVisibility // ignore: cast_nullable_to_non_nullable
                      as Visibility,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProfileImplCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$$ProfileImplCopyWith(
    _$ProfileImpl value,
    $Res Function(_$ProfileImpl) then,
  ) = __$$ProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    DateTime? birthday,
    String? gender,
    String? occupation,
    String? bio,
    @JsonKey(name: 'profile_visibility') Visibility profileVisibility,
    @JsonKey(name: 'wishlist_visibility') Visibility wishlistVisibility,
    @JsonKey(name: 'gift_history_visibility') Visibility giftHistoryVisibility,
  });
}

/// @nodoc
class __$$ProfileImplCopyWithImpl<$Res>
    extends _$ProfileCopyWithImpl<$Res, _$ProfileImpl>
    implements _$$ProfileImplCopyWith<$Res> {
  __$$ProfileImplCopyWithImpl(
    _$ProfileImpl _value,
    $Res Function(_$ProfileImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? username = null,
    Object? displayName = freezed,
    Object? avatarUrl = freezed,
    Object? birthday = freezed,
    Object? gender = freezed,
    Object? occupation = freezed,
    Object? bio = freezed,
    Object? profileVisibility = null,
    Object? wishlistVisibility = null,
    Object? giftHistoryVisibility = null,
  }) {
    return _then(
      _$ProfileImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        username: null == username
            ? _value.username
            : username // ignore: cast_nullable_to_non_nullable
                  as String,
        displayName: freezed == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String?,
        avatarUrl: freezed == avatarUrl
            ? _value.avatarUrl
            : avatarUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        birthday: freezed == birthday
            ? _value.birthday
            : birthday // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        gender: freezed == gender
            ? _value.gender
            : gender // ignore: cast_nullable_to_non_nullable
                  as String?,
        occupation: freezed == occupation
            ? _value.occupation
            : occupation // ignore: cast_nullable_to_non_nullable
                  as String?,
        bio: freezed == bio
            ? _value.bio
            : bio // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileVisibility: null == profileVisibility
            ? _value.profileVisibility
            : profileVisibility // ignore: cast_nullable_to_non_nullable
                  as Visibility,
        wishlistVisibility: null == wishlistVisibility
            ? _value.wishlistVisibility
            : wishlistVisibility // ignore: cast_nullable_to_non_nullable
                  as Visibility,
        giftHistoryVisibility: null == giftHistoryVisibility
            ? _value.giftHistoryVisibility
            : giftHistoryVisibility // ignore: cast_nullable_to_non_nullable
                  as Visibility,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProfileImpl implements _Profile {
  const _$ProfileImpl({
    required this.id,
    required this.username,
    @JsonKey(name: 'display_name') this.displayName,
    @JsonKey(name: 'avatar_url') this.avatarUrl,
    this.birthday,
    this.gender,
    this.occupation,
    this.bio,
    @JsonKey(name: 'profile_visibility')
    this.profileVisibility = Visibility.friends,
    @JsonKey(name: 'wishlist_visibility')
    this.wishlistVisibility = Visibility.friends,
    @JsonKey(name: 'gift_history_visibility')
    this.giftHistoryVisibility = Visibility.friends,
  });

  factory _$ProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String username;
  @override
  @JsonKey(name: 'display_name')
  final String? displayName;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  final DateTime? birthday;
  @override
  final String? gender;
  @override
  final String? occupation;
  @override
  final String? bio;
  @override
  @JsonKey(name: 'profile_visibility')
  final Visibility profileVisibility;
  @override
  @JsonKey(name: 'wishlist_visibility')
  final Visibility wishlistVisibility;
  @override
  @JsonKey(name: 'gift_history_visibility')
  final Visibility giftHistoryVisibility;

  @override
  String toString() {
    return 'Profile(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, birthday: $birthday, gender: $gender, occupation: $occupation, bio: $bio, profileVisibility: $profileVisibility, wishlistVisibility: $wishlistVisibility, giftHistoryVisibility: $giftHistoryVisibility)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.birthday, birthday) ||
                other.birthday == birthday) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.occupation, occupation) ||
                other.occupation == occupation) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profileVisibility, profileVisibility) ||
                other.profileVisibility == profileVisibility) &&
            (identical(other.wishlistVisibility, wishlistVisibility) ||
                other.wishlistVisibility == wishlistVisibility) &&
            (identical(other.giftHistoryVisibility, giftHistoryVisibility) ||
                other.giftHistoryVisibility == giftHistoryVisibility));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    username,
    displayName,
    avatarUrl,
    birthday,
    gender,
    occupation,
    bio,
    profileVisibility,
    wishlistVisibility,
    giftHistoryVisibility,
  );

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      __$$ProfileImplCopyWithImpl<_$ProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProfileImplToJson(this);
  }
}

abstract class _Profile implements Profile {
  const factory _Profile({
    required final String id,
    required final String username,
    @JsonKey(name: 'display_name') final String? displayName,
    @JsonKey(name: 'avatar_url') final String? avatarUrl,
    final DateTime? birthday,
    final String? gender,
    final String? occupation,
    final String? bio,
    @JsonKey(name: 'profile_visibility') final Visibility profileVisibility,
    @JsonKey(name: 'wishlist_visibility') final Visibility wishlistVisibility,
    @JsonKey(name: 'gift_history_visibility')
    final Visibility giftHistoryVisibility,
  }) = _$ProfileImpl;

  factory _Profile.fromJson(Map<String, dynamic> json) = _$ProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get username;
  @override
  @JsonKey(name: 'display_name')
  String? get displayName;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  DateTime? get birthday;
  @override
  String? get gender;
  @override
  String? get occupation;
  @override
  String? get bio;
  @override
  @JsonKey(name: 'profile_visibility')
  Visibility get profileVisibility;
  @override
  @JsonKey(name: 'wishlist_visibility')
  Visibility get wishlistVisibility;
  @override
  @JsonKey(name: 'gift_history_visibility')
  Visibility get giftHistoryVisibility;

  /// Create a copy of Profile
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileImplCopyWith<_$ProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
