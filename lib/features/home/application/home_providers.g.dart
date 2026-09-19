// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeRepositoryHash() => r'300d208acc23eb2765c246b38d652ad2223e6799';

/// See also [homeRepository].
@ProviderFor(homeRepository)
final homeRepositoryProvider = Provider<HomeRepository>.internal(
  homeRepository,
  name: r'homeRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeRepositoryRef = ProviderRef<HomeRepository>;
String _$upcomingBirthdaysHash() => r'72324555c1198bb8abc2c1b7669851ad045ca9f5';

/// Upper Home section: friends' upcoming birthdays (real data).
///
/// Copied from [upcomingBirthdays].
@ProviderFor(upcomingBirthdays)
final upcomingBirthdaysProvider =
    AutoDisposeFutureProvider<List<UpcomingBirthday>>.internal(
      upcomingBirthdays,
      name: r'upcomingBirthdaysProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$upcomingBirthdaysHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UpcomingBirthdaysRef =
    AutoDisposeFutureProviderRef<List<UpcomingBirthday>>;
String _$friendWishlistFeedHash() =>
    r'9d904d1539795ffeb8682a456d8ef1d1af48a31c';

/// Middle Home section: friends' latest wishlist additions (G-82).
///
/// Copied from [friendWishlistFeed].
@ProviderFor(friendWishlistFeed)
final friendWishlistFeedProvider =
    AutoDisposeFutureProvider<List<FriendWishlistItem>>.internal(
      friendWishlistFeed,
      name: r'friendWishlistFeedProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$friendWishlistFeedHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FriendWishlistFeedRef =
    AutoDisposeFutureProviderRef<List<FriendWishlistItem>>;
String _$homeEventsHash() => r'ef45afa89004c535236329e73c562b984eddbe7f';

/// Lower Home section: my real social events (G-82; feed proper is V2/G-210).
///
/// Copied from [homeEvents].
@ProviderFor(homeEvents)
final homeEventsProvider = AutoDisposeFutureProvider<List<HomeEvent>>.internal(
  homeEvents,
  name: r'homeEventsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$homeEventsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef HomeEventsRef = AutoDisposeFutureProviderRef<List<HomeEvent>>;
String _$surpriseTeaserHash() => r'04ef9a766485062d6e6e6f983b720dd864199418';

/// "A surprise is coming" card data (G-210); null = nothing pending.
///
/// Copied from [surpriseTeaser].
@ProviderFor(surpriseTeaser)
final surpriseTeaserProvider =
    AutoDisposeFutureProvider<SurpriseTeaser?>.internal(
      surpriseTeaser,
      name: r'surpriseTeaserProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$surpriseTeaserHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SurpriseTeaserRef = AutoDisposeFutureProviderRef<SurpriseTeaser?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
