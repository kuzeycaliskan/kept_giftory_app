// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pushTokenRepositoryHash() =>
    r'83eecca8cd157baf78b6c7a55baa354c19b5fea2';

/// See also [pushTokenRepository].
@ProviderFor(pushTokenRepository)
final pushTokenRepositoryProvider = Provider<PushTokenRepository>.internal(
  pushTokenRepository,
  name: r'pushTokenRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pushTokenRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PushTokenRepositoryRef = ProviderRef<PushTokenRepository>;
String _$shouldShowPushPrimingHash() =>
    r'468e6b34c1540c54719f982b8058a4c900e7ce58';

/// Whether the Home priming card should show: signed-in real session, push
/// permission not granted yet, and the user hasn't dismissed the card.
///
/// Copied from [shouldShowPushPriming].
@ProviderFor(shouldShowPushPriming)
final shouldShowPushPrimingProvider = AutoDisposeFutureProvider<bool>.internal(
  shouldShowPushPriming,
  name: r'shouldShowPushPrimingProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shouldShowPushPrimingHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShouldShowPushPrimingRef = AutoDisposeFutureProviderRef<bool>;
String _$pushTokenSyncHash() => r'9c942e21836470c88121711c825611864dd82454';

/// Silent token sync: when permission is already granted, keep the stored
/// token fresh on app start (covers FCM rotation, reinstalls, and the case
/// where the first registration failed — e.g. iOS before the APNs
/// entitlement existed). Watched fire-and-forget from Home.
///
/// Copied from [pushTokenSync].
@ProviderFor(pushTokenSync)
final pushTokenSyncProvider = FutureProvider<void>.internal(
  pushTokenSync,
  name: r'pushTokenSyncProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pushTokenSyncHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PushTokenSyncRef = FutureProviderRef<void>;
String _$pushSetupHash() => r'a3bf32a9e379056562d2d0015294f72192368fc2';

/// Push setup actions driven by the priming card (G-61): soft-ask happened in
/// UI, this triggers the OS prompt and registers the token on success.
///
/// Copied from [PushSetup].
@ProviderFor(PushSetup)
final pushSetupProvider =
    AutoDisposeNotifierProvider<PushSetup, AsyncValue<void>>.internal(
      PushSetup.new,
      name: r'pushSetupProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pushSetupHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PushSetup = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
