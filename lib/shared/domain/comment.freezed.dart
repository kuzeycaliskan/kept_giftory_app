// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Comment _$CommentFromJson(Map<String, dynamic> json) {
  return _Comment.fromJson(json);
}

/// @nodoc
mixin _$Comment {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'author_id')
  String get authorId => throw _privateConstructorUsedError;
  String get body => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;
  ProfileCard? get user => throw _privateConstructorUsedError;

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentCopyWith<Comment> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentCopyWith<$Res> {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) then) =
      _$CommentCopyWithImpl<$Res, Comment>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'author_id') String authorId,
    String body,
    @JsonKey(name: 'created_at') DateTime createdAt,
    ProfileCard? user,
  });

  $ProfileCardCopyWith<$Res>? get user;
}

/// @nodoc
class _$CommentCopyWithImpl<$Res, $Val extends Comment>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? body = null,
    Object? createdAt = null,
    Object? user = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            authorId: null == authorId
                ? _value.authorId
                : authorId // ignore: cast_nullable_to_non_nullable
                      as String,
            body: null == body
                ? _value.body
                : body // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            user: freezed == user
                ? _value.user
                : user // ignore: cast_nullable_to_non_nullable
                      as ProfileCard?,
          )
          as $Val,
    );
  }

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCardCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $ProfileCardCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommentImplCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$$CommentImplCopyWith(
    _$CommentImpl value,
    $Res Function(_$CommentImpl) then,
  ) = __$$CommentImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'author_id') String authorId,
    String body,
    @JsonKey(name: 'created_at') DateTime createdAt,
    ProfileCard? user,
  });

  @override
  $ProfileCardCopyWith<$Res>? get user;
}

/// @nodoc
class __$$CommentImplCopyWithImpl<$Res>
    extends _$CommentCopyWithImpl<$Res, _$CommentImpl>
    implements _$$CommentImplCopyWith<$Res> {
  __$$CommentImplCopyWithImpl(
    _$CommentImpl _value,
    $Res Function(_$CommentImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? body = null,
    Object? createdAt = null,
    Object? user = freezed,
  }) {
    return _then(
      _$CommentImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        authorId: null == authorId
            ? _value.authorId
            : authorId // ignore: cast_nullable_to_non_nullable
                  as String,
        body: null == body
            ? _value.body
            : body // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        user: freezed == user
            ? _value.user
            : user // ignore: cast_nullable_to_non_nullable
                  as ProfileCard?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentImpl implements _Comment {
  const _$CommentImpl({
    required this.id,
    @JsonKey(name: 'author_id') required this.authorId,
    required this.body,
    @JsonKey(name: 'created_at') required this.createdAt,
    this.user,
  });

  factory _$CommentImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'author_id')
  final String authorId;
  @override
  final String body;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @override
  final ProfileCard? user;

  @override
  String toString() {
    return 'Comment(id: $id, authorId: $authorId, body: $body, createdAt: $createdAt, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, authorId, body, createdAt, user);

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      __$$CommentImplCopyWithImpl<_$CommentImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentImplToJson(this);
  }
}

abstract class _Comment implements Comment {
  const factory _Comment({
    required final String id,
    @JsonKey(name: 'author_id') required final String authorId,
    required final String body,
    @JsonKey(name: 'created_at') required final DateTime createdAt,
    final ProfileCard? user,
  }) = _$CommentImpl;

  factory _Comment.fromJson(Map<String, dynamic> json) = _$CommentImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'author_id')
  String get authorId;
  @override
  String get body;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  ProfileCard? get user;

  /// Create a copy of Comment
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentImplCopyWith<_$CommentImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
