// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(safetyRepository)
final safetyRepositoryProvider = SafetyRepositoryProvider._();

final class SafetyRepositoryProvider
    extends
        $FunctionalProvider<
          SafetyRepository,
          SafetyRepository,
          SafetyRepository
        >
    with $Provider<SafetyRepository> {
  SafetyRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyRepositoryHash();

  @$internal
  @override
  $ProviderElement<SafetyRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SafetyRepository create(Ref ref) {
    return safetyRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SafetyRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SafetyRepository>(value),
    );
  }
}

String _$safetyRepositoryHash() => r'e749eae55a476d44a8557d263d6515774018ed7a';

/// The caller's block list (Settings → Blocked users).

@ProviderFor(blockedUsers)
final blockedUsersProvider = BlockedUsersProvider._();

/// The caller's block list (Settings → Blocked users).

final class BlockedUsersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProfileCard>>,
          List<ProfileCard>,
          FutureOr<List<ProfileCard>>
        >
    with
        $FutureModifier<List<ProfileCard>>,
        $FutureProvider<List<ProfileCard>> {
  /// The caller's block list (Settings → Blocked users).
  BlockedUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockedUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockedUsersHash();

  @$internal
  @override
  $FutureProviderElement<List<ProfileCard>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProfileCard>> create(Ref ref) {
    return blockedUsers(ref);
  }
}

String _$blockedUsersHash() => r'da4437d09190b01e4cba96060098ffce4a5cbbd8';

/// Block / unblock / report actions. Blocking invalidates every provider
/// that could still be showing the (now invisible) counterpart.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(SafetyController)
final safetyControllerProvider = SafetyControllerProvider._();

/// Block / unblock / report actions. Blocking invalidates every provider
/// that could still be showing the (now invisible) counterpart.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class SafetyControllerProvider
    extends $NotifierProvider<SafetyController, AsyncValue<void>> {
  /// Block / unblock / report actions. Blocking invalidates every provider
  /// that could still be showing the (now invisible) counterpart.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  SafetyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'safetyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$safetyControllerHash();

  @$internal
  @override
  SafetyController create() => SafetyController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$safetyControllerHash() => r'93ddad4f5eca8437a4b9d9200303eccc3afd7de2';

/// Block / unblock / report actions. Blocking invalidates every provider
/// that could still be showing the (now invisible) counterpart.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$SafetyController extends $Notifier<AsyncValue<void>> {
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
