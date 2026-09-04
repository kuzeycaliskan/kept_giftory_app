// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$wishlistRepositoryHash() =>
    r'0a016785f6de27372b9179f02470b89a7c572214';

/// See also [wishlistRepository].
@ProviderFor(wishlistRepository)
final wishlistRepositoryProvider = Provider<WishlistRepository>.internal(
  wishlistRepository,
  name: r'wishlistRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$wishlistRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WishlistRepositoryRef = ProviderRef<WishlistRepository>;
String _$myWishlistHash() => r'dd13f87c90d38ecf1eff009ee56045fb26f55077';

/// See also [myWishlist].
@ProviderFor(myWishlist)
final myWishlistProvider =
    AutoDisposeFutureProvider<List<WishlistItem>>.internal(
      myWishlist,
      name: r'myWishlistProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$myWishlistHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MyWishlistRef = AutoDisposeFutureProviderRef<List<WishlistItem>>;
String _$friendWishlistHash() => r'5e546c3cae3ae7256f78d999462f2279eca3190b';

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

/// A friend's wishlist; RLS decides what the caller may see.
///
/// Copied from [friendWishlist].
@ProviderFor(friendWishlist)
const friendWishlistProvider = FriendWishlistFamily();

/// A friend's wishlist; RLS decides what the caller may see.
///
/// Copied from [friendWishlist].
class FriendWishlistFamily extends Family<AsyncValue<List<WishlistItem>>> {
  /// A friend's wishlist; RLS decides what the caller may see.
  ///
  /// Copied from [friendWishlist].
  const FriendWishlistFamily();

  /// A friend's wishlist; RLS decides what the caller may see.
  ///
  /// Copied from [friendWishlist].
  FriendWishlistProvider call(String profileId) {
    return FriendWishlistProvider(profileId);
  }

  @override
  FriendWishlistProvider getProviderOverride(
    covariant FriendWishlistProvider provider,
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
  String? get name => r'friendWishlistProvider';
}

/// A friend's wishlist; RLS decides what the caller may see.
///
/// Copied from [friendWishlist].
class FriendWishlistProvider
    extends AutoDisposeFutureProvider<List<WishlistItem>> {
  /// A friend's wishlist; RLS decides what the caller may see.
  ///
  /// Copied from [friendWishlist].
  FriendWishlistProvider(String profileId)
    : this._internal(
        (ref) => friendWishlist(ref as FriendWishlistRef, profileId),
        from: friendWishlistProvider,
        name: r'friendWishlistProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$friendWishlistHash,
        dependencies: FriendWishlistFamily._dependencies,
        allTransitiveDependencies:
            FriendWishlistFamily._allTransitiveDependencies,
        profileId: profileId,
      );

  FriendWishlistProvider._internal(
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
    FutureOr<List<WishlistItem>> Function(FriendWishlistRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FriendWishlistProvider._internal(
        (ref) => create(ref as FriendWishlistRef),
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
  AutoDisposeFutureProviderElement<List<WishlistItem>> createElement() {
    return _FriendWishlistProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FriendWishlistProvider && other.profileId == profileId;
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
mixin FriendWishlistRef on AutoDisposeFutureProviderRef<List<WishlistItem>> {
  /// The parameter `profileId` of this provider.
  String get profileId;
}

class _FriendWishlistProviderElement
    extends AutoDisposeFutureProviderElement<List<WishlistItem>>
    with FriendWishlistRef {
  _FriendWishlistProviderElement(super.provider);

  @override
  String get profileId => (origin as FriendWishlistProvider).profileId;
}

String _$wishlistControllerHash() =>
    r'69dcecb22171644d28276df451d1517e78572268';

/// See also [WishlistController].
@ProviderFor(WishlistController)
final wishlistControllerProvider =
    AutoDisposeNotifierProvider<WishlistController, AsyncValue<void>>.internal(
      WishlistController.new,
      name: r'wishlistControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$wishlistControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$WishlistController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
