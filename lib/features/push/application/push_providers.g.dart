// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(pushTokenRepository)
final pushTokenRepositoryProvider = PushTokenRepositoryProvider._();

final class PushTokenRepositoryProvider
    extends
        $FunctionalProvider<
          PushTokenRepository,
          PushTokenRepository,
          PushTokenRepository
        >
    with $Provider<PushTokenRepository> {
  PushTokenRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushTokenRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushTokenRepositoryHash();

  @$internal
  @override
  $ProviderElement<PushTokenRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PushTokenRepository create(Ref ref) {
    return pushTokenRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PushTokenRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PushTokenRepository>(value),
    );
  }
}

String _$pushTokenRepositoryHash() =>
    r'83eecca8cd157baf78b6c7a55baa354c19b5fea2';

/// Whether the Home priming card should show: signed-in real session, push
/// permission not granted yet, and the user hasn't dismissed the card.

@ProviderFor(shouldShowPushPriming)
final shouldShowPushPrimingProvider = ShouldShowPushPrimingProvider._();

/// Whether the Home priming card should show: signed-in real session, push
/// permission not granted yet, and the user hasn't dismissed the card.

final class ShouldShowPushPrimingProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the Home priming card should show: signed-in real session, push
  /// permission not granted yet, and the user hasn't dismissed the card.
  ShouldShowPushPrimingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shouldShowPushPrimingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shouldShowPushPrimingHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return shouldShowPushPriming(ref);
  }
}

String _$shouldShowPushPrimingHash() =>
    r'9ec5373e4f6bdf8ae4f33e58147a57646c39fcb6';

/// Silent token sync: when permission is already granted, keep the stored
/// token fresh on app start (covers FCM rotation, reinstalls, and the case
/// where the first registration failed — e.g. iOS before the APNs
/// entitlement existed). Watched fire-and-forget from Home.

@ProviderFor(pushTokenSync)
final pushTokenSyncProvider = PushTokenSyncProvider._();

/// Silent token sync: when permission is already granted, keep the stored
/// token fresh on app start (covers FCM rotation, reinstalls, and the case
/// where the first registration failed — e.g. iOS before the APNs
/// entitlement existed). Watched fire-and-forget from Home.

final class PushTokenSyncProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
  /// Silent token sync: when permission is already granted, keep the stored
  /// token fresh on app start (covers FCM rotation, reinstalls, and the case
  /// where the first registration failed — e.g. iOS before the APNs
  /// entitlement existed). Watched fire-and-forget from Home.
  PushTokenSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushTokenSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushTokenSyncHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return pushTokenSync(ref);
  }
}

String _$pushTokenSyncHash() => r'613e2fde1cb12c27e57016930655b7813266ae29';

/// Push setup actions driven by the priming card (G-61): soft-ask happened in
/// UI, this triggers the OS prompt and registers the token on success.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(PushSetup)
final pushSetupProvider = PushSetupProvider._();

/// Push setup actions driven by the priming card (G-61): soft-ask happened in
/// UI, this triggers the OS prompt and registers the token on success.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class PushSetupProvider
    extends $NotifierProvider<PushSetup, AsyncValue<void>> {
  /// Push setup actions driven by the priming card (G-61): soft-ask happened in
  /// UI, this triggers the OS prompt and registers the token on success.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  PushSetupProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pushSetupProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pushSetupHash();

  @$internal
  @override
  PushSetup create() => PushSetup();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$pushSetupHash() => r'3cfc84e95831a8617654a5a0aadc82b59d7138d4';

/// Push setup actions driven by the priming card (G-61): soft-ask happened in
/// UI, this triggers the OS prompt and registers the token on success.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$PushSetup extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
