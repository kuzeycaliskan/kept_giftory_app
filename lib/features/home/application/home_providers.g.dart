// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$homeRepositoryHash() => r'2922289e92dcd6bb017b8ded13b7eda8f8d5caed';

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
String _$activityRepositoryHash() =>
    r'7b0db099fb5d09ac0e4a509db632b1356774d6fa';

/// See also [activityRepository].
@ProviderFor(activityRepository)
final activityRepositoryProvider = Provider<ActivityRepository>.internal(
  activityRepository,
  name: r'activityRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activityRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActivityRepositoryRef = ProviderRef<ActivityRepository>;
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
String _$recentActivityHash() => r'422168fc1a8a33ec018545cc518c74fac73af37d';

/// Lower Home section: activity feed (mock in V1, real in V2 — G-210).
///
/// Copied from [recentActivity].
@ProviderFor(recentActivity)
final recentActivityProvider =
    AutoDisposeFutureProvider<List<ActivityItem>>.internal(
      recentActivity,
      name: r'recentActivityProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$recentActivityHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef RecentActivityRef = AutoDisposeFutureProviderRef<List<ActivityItem>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
