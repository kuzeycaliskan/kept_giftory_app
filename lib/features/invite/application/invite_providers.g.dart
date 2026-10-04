// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(inviteRepository)
final inviteRepositoryProvider = InviteRepositoryProvider._();

final class InviteRepositoryProvider
    extends
        $FunctionalProvider<
          InviteRepository,
          InviteRepository,
          InviteRepository
        >
    with $Provider<InviteRepository> {
  InviteRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteRepositoryHash();

  @$internal
  @override
  $ProviderElement<InviteRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  InviteRepository create(Ref ref) {
    return inviteRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(InviteRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<InviteRepository>(value),
    );
  }
}

String _$inviteRepositoryHash() => r'e011f54bb68f548daf192c9f0d8a5baf38891584';

@ProviderFor(myInviteCode)
final myInviteCodeProvider = MyInviteCodeProvider._();

final class MyInviteCodeProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  MyInviteCodeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myInviteCodeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myInviteCodeHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return myInviteCode(ref);
  }
}

String _$myInviteCodeHash() => r'cb8a3998e70501d0336a5293c4971dc664422aca';

@ProviderFor(InviteController)
final inviteControllerProvider = InviteControllerProvider._();

final class InviteControllerProvider
    extends $NotifierProvider<InviteController, AsyncValue<void>> {
  InviteControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inviteControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inviteControllerHash();

  @$internal
  @override
  InviteController create() => InviteController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$inviteControllerHash() => r'f62f6d925954f8432eca4946b652a3eb418a4b75';

abstract class _$InviteController extends $Notifier<AsyncValue<void>> {
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
