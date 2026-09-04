// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gifts_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$giftRepositoryHash() => r'21284827f7963380721ffc9e75ba894c40bfbc21';

/// See also [giftRepository].
@ProviderFor(giftRepository)
final giftRepositoryProvider = Provider<GiftRepository>.internal(
  giftRepository,
  name: r'giftRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$giftRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GiftRepositoryRef = ProviderRef<GiftRepository>;
String _$givenGiftsHash() => r'8c4b6e9d7c629fe2e1a58cd2971a643e9c76965e';

/// See also [givenGifts].
@ProviderFor(givenGifts)
final givenGiftsProvider = AutoDisposeFutureProvider<List<GiftEntry>>.internal(
  givenGifts,
  name: r'givenGiftsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$givenGiftsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GivenGiftsRef = AutoDisposeFutureProviderRef<List<GiftEntry>>;
String _$receivedGiftsHash() => r'9dbbafe0276b23a7521aa3633b536c4284ee2469';

/// See also [receivedGifts].
@ProviderFor(receivedGifts)
final receivedGiftsProvider =
    AutoDisposeFutureProvider<List<GiftEntry>>.internal(
      receivedGifts,
      name: r'receivedGiftsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$receivedGiftsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ReceivedGiftsRef = AutoDisposeFutureProviderRef<List<GiftEntry>>;
String _$friendGiftHistoryHash() => r'fd3d520d35c063ffe50078179d483671217d60dc';

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

/// A friend's gift history (G-52); RLS applies visibility + surprise rules.
///
/// Copied from [friendGiftHistory].
@ProviderFor(friendGiftHistory)
const friendGiftHistoryProvider = FriendGiftHistoryFamily();

/// A friend's gift history (G-52); RLS applies visibility + surprise rules.
///
/// Copied from [friendGiftHistory].
class FriendGiftHistoryFamily extends Family<AsyncValue<List<GiftEntry>>> {
  /// A friend's gift history (G-52); RLS applies visibility + surprise rules.
  ///
  /// Copied from [friendGiftHistory].
  const FriendGiftHistoryFamily();

  /// A friend's gift history (G-52); RLS applies visibility + surprise rules.
  ///
  /// Copied from [friendGiftHistory].
  FriendGiftHistoryProvider call(String profileId) {
    return FriendGiftHistoryProvider(profileId);
  }

  @override
  FriendGiftHistoryProvider getProviderOverride(
    covariant FriendGiftHistoryProvider provider,
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
  String? get name => r'friendGiftHistoryProvider';
}

/// A friend's gift history (G-52); RLS applies visibility + surprise rules.
///
/// Copied from [friendGiftHistory].
class FriendGiftHistoryProvider
    extends AutoDisposeFutureProvider<List<GiftEntry>> {
  /// A friend's gift history (G-52); RLS applies visibility + surprise rules.
  ///
  /// Copied from [friendGiftHistory].
  FriendGiftHistoryProvider(String profileId)
    : this._internal(
        (ref) => friendGiftHistory(ref as FriendGiftHistoryRef, profileId),
        from: friendGiftHistoryProvider,
        name: r'friendGiftHistoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$friendGiftHistoryHash,
        dependencies: FriendGiftHistoryFamily._dependencies,
        allTransitiveDependencies:
            FriendGiftHistoryFamily._allTransitiveDependencies,
        profileId: profileId,
      );

  FriendGiftHistoryProvider._internal(
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
    FutureOr<List<GiftEntry>> Function(FriendGiftHistoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: FriendGiftHistoryProvider._internal(
        (ref) => create(ref as FriendGiftHistoryRef),
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
  AutoDisposeFutureProviderElement<List<GiftEntry>> createElement() {
    return _FriendGiftHistoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FriendGiftHistoryProvider && other.profileId == profileId;
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
mixin FriendGiftHistoryRef on AutoDisposeFutureProviderRef<List<GiftEntry>> {
  /// The parameter `profileId` of this provider.
  String get profileId;
}

class _FriendGiftHistoryProviderElement
    extends AutoDisposeFutureProviderElement<List<GiftEntry>>
    with FriendGiftHistoryRef {
  _FriendGiftHistoryProviderElement(super.provider);

  @override
  String get profileId => (origin as FriendGiftHistoryProvider).profileId;
}

String _$giftsControllerHash() => r'df23a9de55685a8b4b8db00f939f64e08ed70d4b';

/// See also [GiftsController].
@ProviderFor(GiftsController)
final giftsControllerProvider =
    AutoDisposeNotifierProvider<GiftsController, AsyncValue<void>>.internal(
      GiftsController.new,
      name: r'giftsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$giftsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GiftsController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
