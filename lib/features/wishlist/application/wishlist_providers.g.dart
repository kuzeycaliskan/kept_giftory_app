// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wishlist_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(wishlistRepository)
final wishlistRepositoryProvider = WishlistRepositoryProvider._();

final class WishlistRepositoryProvider
    extends
        $FunctionalProvider<
          WishlistRepository,
          WishlistRepository,
          WishlistRepository
        >
    with $Provider<WishlistRepository> {
  WishlistRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistRepositoryHash();

  @$internal
  @override
  $ProviderElement<WishlistRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WishlistRepository create(Ref ref) {
    return wishlistRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WishlistRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WishlistRepository>(value),
    );
  }
}

String _$wishlistRepositoryHash() =>
    r'0a016785f6de27372b9179f02470b89a7c572214';

@ProviderFor(myWishlist)
final myWishlistProvider = MyWishlistProvider._();

final class MyWishlistProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WishlistItem>>,
          List<WishlistItem>,
          FutureOr<List<WishlistItem>>
        >
    with
        $FutureModifier<List<WishlistItem>>,
        $FutureProvider<List<WishlistItem>> {
  MyWishlistProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myWishlistProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myWishlistHash();

  @$internal
  @override
  $FutureProviderElement<List<WishlistItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WishlistItem>> create(Ref ref) {
    return myWishlist(ref);
  }
}

String _$myWishlistHash() => r'dd13f87c90d38ecf1eff009ee56045fb26f55077';

/// A friend's wishlist; RLS decides what the caller may see.

@ProviderFor(friendWishlist)
final friendWishlistProvider = FriendWishlistFamily._();

/// A friend's wishlist; RLS decides what the caller may see.

final class FriendWishlistProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WishlistItem>>,
          List<WishlistItem>,
          FutureOr<List<WishlistItem>>
        >
    with
        $FutureModifier<List<WishlistItem>>,
        $FutureProvider<List<WishlistItem>> {
  /// A friend's wishlist; RLS decides what the caller may see.
  FriendWishlistProvider._({
    required FriendWishlistFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'friendWishlistProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$friendWishlistHash();

  @override
  String toString() {
    return r'friendWishlistProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WishlistItem>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WishlistItem>> create(Ref ref) {
    final argument = this.argument as String;
    return friendWishlist(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FriendWishlistProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$friendWishlistHash() => r'5e546c3cae3ae7256f78d999462f2279eca3190b';

/// A friend's wishlist; RLS decides what the caller may see.

final class FriendWishlistFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<WishlistItem>>, String> {
  FriendWishlistFamily._()
    : super(
        retry: null,
        name: r'friendWishlistProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// A friend's wishlist; RLS decides what the caller may see.

  FriendWishlistProvider call(String profileId) =>
      FriendWishlistProvider._(argument: profileId, from: this);

  @override
  String toString() => r'friendWishlistProvider';
}

@ProviderFor(WishlistController)
final wishlistControllerProvider = WishlistControllerProvider._();

final class WishlistControllerProvider
    extends $NotifierProvider<WishlistController, AsyncValue<void>> {
  WishlistControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'wishlistControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$wishlistControllerHash();

  @$internal
  @override
  WishlistController create() => WishlistController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$wishlistControllerHash() =>
    r'121ab77a8950ee80553c6b79225983c5e8f0dd4c';

abstract class _$WishlistController extends $Notifier<AsyncValue<void>> {
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
