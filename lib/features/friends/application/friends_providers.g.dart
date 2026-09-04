// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$friendshipRepositoryHash() =>
    r'5f9d002d4865060b9a87b2d91c2652949d7f17b9';

/// See also [friendshipRepository].
@ProviderFor(friendshipRepository)
final friendshipRepositoryProvider = Provider<FriendshipRepository>.internal(
  friendshipRepository,
  name: r'friendshipRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$friendshipRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FriendshipRepositoryRef = ProviderRef<FriendshipRepository>;
String _$friendEntriesHash() => r'a17dfc8eb340908e84fbd8ad14e4cab358bdac60';

/// All friendship rows for the Friends screen (friends + pending requests).
///
/// Copied from [friendEntries].
@ProviderFor(friendEntries)
final friendEntriesProvider =
    AutoDisposeFutureProvider<List<FriendEntry>>.internal(
      friendEntries,
      name: r'friendEntriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$friendEntriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FriendEntriesRef = AutoDisposeFutureProviderRef<List<FriendEntry>>;
String _$friendsControllerHash() => r'fa1eaf3939deb9b332bb9ff5830971a3213afa93';

/// Mutations for the Friends screen; refreshes the list on success.
///
/// Copied from [FriendsController].
@ProviderFor(FriendsController)
final friendsControllerProvider =
    AutoDisposeNotifierProvider<FriendsController, AsyncValue<void>>.internal(
      FriendsController.new,
      name: r'friendsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$friendsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$FriendsController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
