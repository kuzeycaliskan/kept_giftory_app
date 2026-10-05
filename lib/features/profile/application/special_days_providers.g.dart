// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'special_days_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(specialDaysRepository)
final specialDaysRepositoryProvider = SpecialDaysRepositoryProvider._();

final class SpecialDaysRepositoryProvider
    extends
        $FunctionalProvider<
          SpecialDaysRepository,
          SpecialDaysRepository,
          SpecialDaysRepository
        >
    with $Provider<SpecialDaysRepository> {
  SpecialDaysRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'specialDaysRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$specialDaysRepositoryHash();

  @$internal
  @override
  $ProviderElement<SpecialDaysRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SpecialDaysRepository create(Ref ref) {
    return specialDaysRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SpecialDaysRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SpecialDaysRepository>(value),
    );
  }
}

String _$specialDaysRepositoryHash() =>
    r'cde7d94efb17b0eb6c7e6d0336b7a114d3d89652';

/// My announced occasions, soonest first (G-410b).

@ProviderFor(mySpecialDays)
final mySpecialDaysProvider = MySpecialDaysProvider._();

/// My announced occasions, soonest first (G-410b).

final class MySpecialDaysProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SpecialDay>>,
          List<SpecialDay>,
          FutureOr<List<SpecialDay>>
        >
    with $FutureModifier<List<SpecialDay>>, $FutureProvider<List<SpecialDay>> {
  /// My announced occasions, soonest first (G-410b).
  MySpecialDaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySpecialDaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySpecialDaysHash();

  @$internal
  @override
  $FutureProviderElement<List<SpecialDay>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<SpecialDay>> create(Ref ref) {
    return mySpecialDays(ref);
  }
}

String _$mySpecialDaysHash() => r'c0a868855c44c4887a2cde728c59668483dd6b4a';

@ProviderFor(SpecialDaysController)
final specialDaysControllerProvider = SpecialDaysControllerProvider._();

final class SpecialDaysControllerProvider
    extends $NotifierProvider<SpecialDaysController, AsyncValue<void>> {
  SpecialDaysControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'specialDaysControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$specialDaysControllerHash();

  @$internal
  @override
  SpecialDaysController create() => SpecialDaysController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$specialDaysControllerHash() =>
    r'1fe7cc194a19978412f3d671b1a60df8778f9bcc';

abstract class _$SpecialDaysController extends $Notifier<AsyncValue<void>> {
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
