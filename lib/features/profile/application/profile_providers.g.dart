// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'f96d558644afa64031ba545ccd54796f11f9ee68';

/// The signed-in user's profile; null while onboarding is incomplete.

@ProviderFor(myProfile)
final myProfileProvider = MyProfileProvider._();

/// The signed-in user's profile; null while onboarding is incomplete.

final class MyProfileProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, FutureOr<Profile?>>
    with $FutureModifier<Profile?>, $FutureProvider<Profile?> {
  /// The signed-in user's profile; null while onboarding is incomplete.
  MyProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileHash();

  @$internal
  @override
  $FutureProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile?> create(Ref ref) {
    return myProfile(ref);
  }
}

String _$myProfileHash() => r'add24e36b5a9ebf326675ced988a41f319642ed0';

/// Another user's profile; null when RLS hides it (G-84).

@ProviderFor(userProfile)
final userProfileProvider = UserProfileFamily._();

/// Another user's profile; null when RLS hides it (G-84).

final class UserProfileProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, FutureOr<Profile?>>
    with $FutureModifier<Profile?>, $FutureProvider<Profile?> {
  /// Another user's profile; null when RLS hides it (G-84).
  UserProfileProvider._({
    required UserProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userProfileHash();

  @override
  String toString() {
    return r'userProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile?> create(Ref ref) {
    final argument = this.argument as String;
    return userProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userProfileHash() => r'8e343f4fd31631c02b935cd51ec343f340b26b49';

/// Another user's profile; null when RLS hides it (G-84).

final class UserProfileFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Profile?>, String> {
  UserProfileFamily._()
    : super(
        retry: null,
        name: r'userProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Another user's profile; null when RLS hides it (G-84).

  UserProfileProvider call(String profileId) =>
      UserProfileProvider._(argument: profileId, from: this);

  @override
  String toString() => r'userProfileProvider';
}

/// Username / display-name search results (G-32). The screen debounces input
/// before touching this family, so each distinct query hits the network once.

@ProviderFor(profileSearch)
final profileSearchProvider = ProfileSearchFamily._();

/// Username / display-name search results (G-32). The screen debounces input
/// before touching this family, so each distinct query hits the network once.

final class ProfileSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProfileCard>>,
          List<ProfileCard>,
          FutureOr<List<ProfileCard>>
        >
    with
        $FutureModifier<List<ProfileCard>>,
        $FutureProvider<List<ProfileCard>> {
  /// Username / display-name search results (G-32). The screen debounces input
  /// before touching this family, so each distinct query hits the network once.
  ProfileSearchProvider._({
    required ProfileSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileSearchHash();

  @override
  String toString() {
    return r'profileSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProfileCard>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProfileCard>> create(Ref ref) {
    final argument = this.argument as String;
    return profileSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileSearchHash() => r'0741c9f1f4e70400ad7311e6ac89552ad5c34eda';

/// Username / display-name search results (G-32). The screen debounces input
/// before touching this family, so each distinct query hits the network once.

final class ProfileSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ProfileCard>>, String> {
  ProfileSearchFamily._()
    : super(
        retry: null,
        name: r'profileSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Username / display-name search results (G-32). The screen debounces input
  /// before touching this family, so each distinct query hits the network once.

  ProfileSearchProvider call(String query) =>
      ProfileSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'profileSearchProvider';
}

/// Minimal card for a user whose full profile is RLS-hidden — powers the
/// private-profile state (avatar + name + request button, G-32).

@ProviderFor(profileCard)
final profileCardProvider = ProfileCardFamily._();

/// Minimal card for a user whose full profile is RLS-hidden — powers the
/// private-profile state (avatar + name + request button, G-32).

final class ProfileCardProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProfileCard?>,
          ProfileCard?,
          FutureOr<ProfileCard?>
        >
    with $FutureModifier<ProfileCard?>, $FutureProvider<ProfileCard?> {
  /// Minimal card for a user whose full profile is RLS-hidden — powers the
  /// private-profile state (avatar + name + request button, G-32).
  ProfileCardProvider._({
    required ProfileCardFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileCardProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileCardHash();

  @override
  String toString() {
    return r'profileCardProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProfileCard?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProfileCard?> create(Ref ref) {
    final argument = this.argument as String;
    return profileCard(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileCardProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileCardHash() => r'f48f519a5a6994be8a4fa11c38100e8bc21322cc';

/// Minimal card for a user whose full profile is RLS-hidden — powers the
/// private-profile state (avatar + name + request button, G-32).

final class ProfileCardFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProfileCard?>, String> {
  ProfileCardFamily._()
    : super(
        retry: null,
        name: r'profileCardProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Minimal card for a user whose full profile is RLS-hidden — powers the
  /// private-profile state (avatar + name + request button, G-32).

  ProfileCardProvider call(String profileId) =>
      ProfileCardProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileCardProvider';
}
