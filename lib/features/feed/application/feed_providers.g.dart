// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$feedRepositoryHash() => r'ca7114f71c1036434e7f8136b38925b18731913b';

/// See also [feedRepository].
@ProviderFor(feedRepository)
final feedRepositoryProvider = Provider<FeedRepository>.internal(
  feedRepository,
  name: r'feedRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$feedRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FeedRepositoryRef = ProviderRef<FeedRepository>;
String _$storyGroupsHash() => r'0bbf8dda63ddd1abfba0eeaebec22f4142a0a206';

/// The strip's data: live posts grouped per author, viewer first.
///
/// Copied from [storyGroups].
@ProviderFor(storyGroups)
final storyGroupsProvider =
    AutoDisposeFutureProvider<List<StoryGroup>>.internal(
      storyGroups,
      name: r'storyGroupsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$storyGroupsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef StoryGroupsRef = AutoDisposeFutureProviderRef<List<StoryGroup>>;
String _$seenPostsHash() => r'ccdbcdec8193d5848ffb491a486a9aa855b78df8';

/// Device-local "already watched" markers (ring colour in the strip). Purely
/// a UI nicety, so it lives in preferences, not Postgres.
///
/// Copied from [SeenPosts].
@ProviderFor(SeenPosts)
final seenPostsProvider = NotifierProvider<SeenPosts, Set<String>>.internal(
  SeenPosts.new,
  name: r'seenPostsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$seenPostsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SeenPosts = Notifier<Set<String>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
