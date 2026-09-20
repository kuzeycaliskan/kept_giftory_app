// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'claims_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$claimsRepositoryHash() => r'6a3f840ad39a246089b2faad1a1bea7fd78302ec';

/// See also [claimsRepository].
@ProviderFor(claimsRepository)
final claimsRepositoryProvider = Provider<ClaimsRepository>.internal(
  claimsRepository,
  name: r'claimsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$claimsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ClaimsRepositoryRef = ProviderRef<ClaimsRepository>;
String _$wishlistClaimsHash() => r'4542ba135840538302112b5fceee3a55e2237484';

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

/// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).
///
/// Copied from [wishlistClaims].
@ProviderFor(wishlistClaims)
const wishlistClaimsProvider = WishlistClaimsFamily();

/// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).
///
/// Copied from [wishlistClaims].
class WishlistClaimsFamily
    extends Family<AsyncValue<Map<String, WishlistClaim>>> {
  /// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).
  ///
  /// Copied from [wishlistClaims].
  const WishlistClaimsFamily();

  /// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).
  ///
  /// Copied from [wishlistClaims].
  WishlistClaimsProvider call(String ownerId) {
    return WishlistClaimsProvider(ownerId);
  }

  @override
  WishlistClaimsProvider getProviderOverride(
    covariant WishlistClaimsProvider provider,
  ) {
    return call(provider.ownerId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'wishlistClaimsProvider';
}

/// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).
///
/// Copied from [wishlistClaims].
class WishlistClaimsProvider
    extends AutoDisposeFutureProvider<Map<String, WishlistClaim>> {
  /// Claims on a friend's list, keyed by item id. Empty for the owner (RLS).
  ///
  /// Copied from [wishlistClaims].
  WishlistClaimsProvider(String ownerId)
    : this._internal(
        (ref) => wishlistClaims(ref as WishlistClaimsRef, ownerId),
        from: wishlistClaimsProvider,
        name: r'wishlistClaimsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$wishlistClaimsHash,
        dependencies: WishlistClaimsFamily._dependencies,
        allTransitiveDependencies:
            WishlistClaimsFamily._allTransitiveDependencies,
        ownerId: ownerId,
      );

  WishlistClaimsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.ownerId,
  }) : super.internal();

  final String ownerId;

  @override
  Override overrideWith(
    FutureOr<Map<String, WishlistClaim>> Function(WishlistClaimsRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WishlistClaimsProvider._internal(
        (ref) => create(ref as WishlistClaimsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        ownerId: ownerId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Map<String, WishlistClaim>> createElement() {
    return _WishlistClaimsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WishlistClaimsProvider && other.ownerId == ownerId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, ownerId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin WishlistClaimsRef
    on AutoDisposeFutureProviderRef<Map<String, WishlistClaim>> {
  /// The parameter `ownerId` of this provider.
  String get ownerId;
}

class _WishlistClaimsProviderElement
    extends AutoDisposeFutureProviderElement<Map<String, WishlistClaim>>
    with WishlistClaimsRef {
  _WishlistClaimsProviderElement(super.provider);

  @override
  String get ownerId => (origin as WishlistClaimsProvider).ownerId;
}

String _$claimsControllerHash() => r'ef5dcd7c6ca94df00576900f327b3d56231826db';

/// Mutations on claims and pledges. Each method returns the failure (null
/// on success) so the row can explain a lost race in place; the list for
/// that owner is refreshed either way — the server is the truth.
///
/// Copied from [ClaimsController].
@ProviderFor(ClaimsController)
final claimsControllerProvider =
    AutoDisposeNotifierProvider<ClaimsController, AsyncValue<void>>.internal(
      ClaimsController.new,
      name: r'claimsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$claimsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ClaimsController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
