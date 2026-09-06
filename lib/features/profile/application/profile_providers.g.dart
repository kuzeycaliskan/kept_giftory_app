// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$profileRepositoryHash() => r'f96d558644afa64031ba545ccd54796f11f9ee68';

/// See also [profileRepository].
@ProviderFor(profileRepository)
final profileRepositoryProvider = Provider<ProfileRepository>.internal(
  profileRepository,
  name: r'profileRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$profileRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ProfileRepositoryRef = ProviderRef<ProfileRepository>;
String _$myProfileHash() => r'add24e36b5a9ebf326675ced988a41f319642ed0';

/// The signed-in user's profile; null while onboarding is incomplete.
///
/// Copied from [myProfile].
@ProviderFor(myProfile)
final myProfileProvider = AutoDisposeFutureProvider<Profile?>.internal(
  myProfile,
  name: r'myProfileProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$myProfileHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyProfileRef = AutoDisposeFutureProviderRef<Profile?>;
String _$userProfileHash() => r'8e343f4fd31631c02b935cd51ec343f340b26b49';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Another user's profile; null when RLS hides it (G-84).
///
/// Copied from [userProfile].
@ProviderFor(userProfile)
const userProfileProvider = UserProfileFamily();

/// Another user's profile; null when RLS hides it (G-84).
///
/// Copied from [userProfile].
class UserProfileFamily extends Family<AsyncValue<Profile?>> {
  /// Another user's profile; null when RLS hides it (G-84).
  ///
  /// Copied from [userProfile].
  const UserProfileFamily();

  /// Another user's profile; null when RLS hides it (G-84).
  ///
  /// Copied from [userProfile].
  UserProfileProvider call(String profileId) {
    return UserProfileProvider(profileId);
  }

  @override
  UserProfileProvider getProviderOverride(
    covariant UserProfileProvider provider,
  ) {
    return call(provider.profileId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'userProfileProvider';
}

/// Another user's profile; null when RLS hides it (G-84).
///
/// Copied from [userProfile].
class UserProfileProvider extends AutoDisposeFutureProvider<Profile?> {
  /// Another user's profile; null when RLS hides it (G-84).
  ///
  /// Copied from [userProfile].
  UserProfileProvider(String profileId)
    : this._internal(
        (ref) => userProfile(ref as UserProfileRef, profileId),
        from: userProfileProvider,
        name: r'userProfileProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$userProfileHash,
        dependencies: UserProfileFamily._dependencies,
        allTransitiveDependencies: UserProfileFamily._allTransitiveDependencies,
        profileId: profileId,
      );

  UserProfileProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.profileId,
  }) : super.internal();

  final String profileId;

  @override
  Override overrideWith(
    FutureOr<Profile?> Function(UserProfileRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: UserProfileProvider._internal(
        (ref) => create(ref as UserProfileRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        profileId: profileId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Profile?> createElement() {
    return _UserProfileProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.profileId == profileId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, profileId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin UserProfileRef on AutoDisposeFutureProviderRef<Profile?> {
  /// The parameter `profileId` of this provider.
  String get profileId;
}

class _UserProfileProviderElement
    extends AutoDisposeFutureProviderElement<Profile?>
    with UserProfileRef {
  _UserProfileProviderElement(super.provider);

  @override
  String get profileId => (origin as UserProfileProvider).profileId;
}

String _$profileSearchHash() => r'0741c9f1f4e70400ad7311e6ac89552ad5c34eda';

/// Username / display-name search results (G-32). The screen debounces input
/// before touching this family, so each distinct query hits the network once.
///
/// Copied from [profileSearch].
@ProviderFor(profileSearch)
const profileSearchProvider = ProfileSearchFamily();

/// Username / display-name search results (G-32). The screen debounces input
/// before touching this family, so each distinct query hits the network once.
///
/// Copied from [profileSearch].
class ProfileSearchFamily extends Family<AsyncValue<List<ProfileCard>>> {
  /// Username / display-name search results (G-32). The screen debounces input
  /// before touching this family, so each distinct query hits the network once.
  ///
  /// Copied from [profileSearch].
  const ProfileSearchFamily();

  /// Username / display-name search results (G-32). The screen debounces input
  /// before touching this family, so each distinct query hits the network once.
  ///
  /// Copied from [profileSearch].
  ProfileSearchProvider call(String query) {
    return ProfileSearchProvider(query);
  }

  @override
  ProfileSearchProvider getProviderOverride(
    covariant ProfileSearchProvider provider,
  ) {
    return call(provider.query);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileSearchProvider';
}

/// Username / display-name search results (G-32). The screen debounces input
/// before touching this family, so each distinct query hits the network once.
///
/// Copied from [profileSearch].
class ProfileSearchProvider
    extends AutoDisposeFutureProvider<List<ProfileCard>> {
  /// Username / display-name search results (G-32). The screen debounces input
  /// before touching this family, so each distinct query hits the network once.
  ///
  /// Copied from [profileSearch].
  ProfileSearchProvider(String query)
    : this._internal(
        (ref) => profileSearch(ref as ProfileSearchRef, query),
        from: profileSearchProvider,
        name: r'profileSearchProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileSearchHash,
        dependencies: ProfileSearchFamily._dependencies,
        allTransitiveDependencies:
            ProfileSearchFamily._allTransitiveDependencies,
        query: query,
      );

  ProfileSearchProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.query,
  }) : super.internal();

  final String query;

  @override
  Override overrideWith(
    FutureOr<List<ProfileCard>> Function(ProfileSearchRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileSearchProvider._internal(
        (ref) => create(ref as ProfileSearchRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        query: query,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<ProfileCard>> createElement() {
    return _ProfileSearchProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileSearchProvider && other.query == query;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, query.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileSearchRef on AutoDisposeFutureProviderRef<List<ProfileCard>> {
  /// The parameter `query` of this provider.
  String get query;
}

class _ProfileSearchProviderElement
    extends AutoDisposeFutureProviderElement<List<ProfileCard>>
    with ProfileSearchRef {
  _ProfileSearchProviderElement(super.provider);

  @override
  String get query => (origin as ProfileSearchProvider).query;
}

String _$profileCardHash() => r'f48f519a5a6994be8a4fa11c38100e8bc21322cc';

/// Minimal card for a user whose full profile is RLS-hidden — powers the
/// private-profile state (avatar + name + request button, G-32).
///
/// Copied from [profileCard].
@ProviderFor(profileCard)
const profileCardProvider = ProfileCardFamily();

/// Minimal card for a user whose full profile is RLS-hidden — powers the
/// private-profile state (avatar + name + request button, G-32).
///
/// Copied from [profileCard].
class ProfileCardFamily extends Family<AsyncValue<ProfileCard?>> {
  /// Minimal card for a user whose full profile is RLS-hidden — powers the
  /// private-profile state (avatar + name + request button, G-32).
  ///
  /// Copied from [profileCard].
  const ProfileCardFamily();

  /// Minimal card for a user whose full profile is RLS-hidden — powers the
  /// private-profile state (avatar + name + request button, G-32).
  ///
  /// Copied from [profileCard].
  ProfileCardProvider call(String profileId) {
    return ProfileCardProvider(profileId);
  }

  @override
  ProfileCardProvider getProviderOverride(
    covariant ProfileCardProvider provider,
  ) {
    return call(provider.profileId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'profileCardProvider';
}

/// Minimal card for a user whose full profile is RLS-hidden — powers the
/// private-profile state (avatar + name + request button, G-32).
///
/// Copied from [profileCard].
class ProfileCardProvider extends AutoDisposeFutureProvider<ProfileCard?> {
  /// Minimal card for a user whose full profile is RLS-hidden — powers the
  /// private-profile state (avatar + name + request button, G-32).
  ///
  /// Copied from [profileCard].
  ProfileCardProvider(String profileId)
    : this._internal(
        (ref) => profileCard(ref as ProfileCardRef, profileId),
        from: profileCardProvider,
        name: r'profileCardProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$profileCardHash,
        dependencies: ProfileCardFamily._dependencies,
        allTransitiveDependencies: ProfileCardFamily._allTransitiveDependencies,
        profileId: profileId,
      );

  ProfileCardProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.profileId,
  }) : super.internal();

  final String profileId;

  @override
  Override overrideWith(
    FutureOr<ProfileCard?> Function(ProfileCardRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: ProfileCardProvider._internal(
        (ref) => create(ref as ProfileCardRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        profileId: profileId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<ProfileCard?> createElement() {
    return _ProfileCardProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileCardProvider && other.profileId == profileId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, profileId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin ProfileCardRef on AutoDisposeFutureProviderRef<ProfileCard?> {
  /// The parameter `profileId` of this provider.
  String get profileId;
}

class _ProfileCardProviderElement
    extends AutoDisposeFutureProviderElement<ProfileCard?>
    with ProfileCardRef {
  _ProfileCardProviderElement(super.provider);

  @override
  String get profileId => (origin as ProfileCardProvider).profileId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
