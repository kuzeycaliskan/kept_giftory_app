// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$safetyRepositoryHash() => r'e749eae55a476d44a8557d263d6515774018ed7a';

/// See also [safetyRepository].
@ProviderFor(safetyRepository)
final safetyRepositoryProvider = Provider<SafetyRepository>.internal(
  safetyRepository,
  name: r'safetyRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$safetyRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SafetyRepositoryRef = ProviderRef<SafetyRepository>;
String _$blockedUsersHash() => r'da4437d09190b01e4cba96060098ffce4a5cbbd8';

/// The caller's block list (Settings → Blocked users).
///
/// Copied from [blockedUsers].
@ProviderFor(blockedUsers)
final blockedUsersProvider =
    AutoDisposeFutureProvider<List<ProfileCard>>.internal(
      blockedUsers,
      name: r'blockedUsersProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$blockedUsersHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BlockedUsersRef = AutoDisposeFutureProviderRef<List<ProfileCard>>;
String _$safetyControllerHash() => r'488d5de0f01766a283f57aaada46b10971b718f3';

/// Block / unblock / report actions. Blocking invalidates every provider
/// that could still be showing the (now invisible) counterpart.
///
/// Copied from [SafetyController].
@ProviderFor(SafetyController)
final safetyControllerProvider =
    AutoDisposeNotifierProvider<SafetyController, AsyncValue<void>>.internal(
      SafetyController.new,
      name: r'safetyControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$safetyControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SafetyController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
