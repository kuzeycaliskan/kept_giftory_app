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
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
