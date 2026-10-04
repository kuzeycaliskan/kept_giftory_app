// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claims_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(claimsRepository)
final claimsRepositoryProvider = ClaimsRepositoryProvider._();

final class ClaimsRepositoryProvider
    extends
        $FunctionalProvider<
          ClaimsRepository,
          ClaimsRepository,
          ClaimsRepository
        >
    with $Provider<ClaimsRepository> {
  ClaimsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claimsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claimsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClaimsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClaimsRepository create(Ref ref) {
    return claimsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClaimsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClaimsRepository>(value),
    );
  }
}

String _$claimsRepositoryHash() => r'6a3f840ad39a246089b2faad1a1bea7fd78302ec';

/// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).

@ProviderFor(wishlistClaims)
final wishlistClaimsProvider = WishlistClaimsFamily._();

/// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).

final class WishlistClaimsProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<String, WishlistClaim>>,
          Map<String, WishlistClaim>,
          FutureOr<Map<String, WishlistClaim>>
        >
    with
        $FutureModifier<Map<String, WishlistClaim>>,
        $FutureProvider<Map<String, WishlistClaim>> {
  /// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).
  WishlistClaimsProvider._({
    required WishlistClaimsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'wishlistClaimsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$wishlistClaimsHash();

  @override
  String toString() {
    return r'wishlistClaimsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Map<String, WishlistClaim>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<String, WishlistClaim>> create(Ref ref) {
    final argument = this.argument as String;
    return wishlistClaims(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WishlistClaimsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$wishlistClaimsHash() => r'4542ba135840538302112b5fceee3a55e2237484';

/// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).

final class WishlistClaimsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<Map<String, WishlistClaim>>,
          String
        > {
  WishlistClaimsFamily._()
    : super(
        retry: null,
        name: r'wishlistClaimsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).

  WishlistClaimsProvider call(String ownerId) =>
      WishlistClaimsProvider._(argument: ownerId, from: this);

  @override
  String toString() => r'wishlistClaimsProvider';
}

/// Mutations on claims and pledges. Each method returns the failure (null
/// on success) so the row can explain a lost race in place; the list for
/// that owner is refreshed either way — the server is the truth.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(ClaimsController)
final claimsControllerProvider = ClaimsControllerProvider._();

/// Mutations on claims and pledges. Each method returns the failure (null
/// on success) so the row can explain a lost race in place; the list for
/// that owner is refreshed either way — the server is the truth.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class ClaimsControllerProvider
    extends $NotifierProvider<ClaimsController, AsyncValue<void>> {
  /// Mutations on claims and pledges. Each method returns the failure (null
  /// on success) so the row can explain a lost race in place; the list for
  /// that owner is refreshed either way — the server is the truth.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  ClaimsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'claimsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$claimsControllerHash();

  @$internal
  @override
  ClaimsController create() => ClaimsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$claimsControllerHash() => r'7c4d65d65830f94c183642f88351cb19b29d80f3';

/// Mutations on claims and pledges. Each method returns the failure (null
/// on success) so the row can explain a lost race in place; the list for
/// that owner is refreshed either way — the server is the truth.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$ClaimsController extends $Notifier<AsyncValue<void>> {
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
