// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(feedRepository)
final feedRepositoryProvider = FeedRepositoryProvider._();

final class FeedRepositoryProvider
    extends $FunctionalProvider<FeedRepository, FeedRepository, FeedRepository>
    with $Provider<FeedRepository> {
  FeedRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedRepository create(Ref ref) {
    return feedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRepository>(value),
    );
  }
}

String _$feedRepositoryHash() => r'ca7114f71c1036434e7f8136b38925b18731913b';

/// The strip's data: live posts grouped per author, viewer first.

@ProviderFor(storyGroups)
final storyGroupsProvider = StoryGroupsProvider._();

/// The strip's data: live posts grouped per author, viewer first.

final class StoryGroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StoryGroup>>,
          List<StoryGroup>,
          FutureOr<List<StoryGroup>>
        >
    with $FutureModifier<List<StoryGroup>>, $FutureProvider<List<StoryGroup>> {
  /// The strip's data: live posts grouped per author, viewer first.
  StoryGroupsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'storyGroupsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$storyGroupsHash();

  @$internal
  @override
  $FutureProviderElement<List<StoryGroup>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StoryGroup>> create(Ref ref) {
    return storyGroups(ref);
  }
}

String _$storyGroupsHash() => r'0bbf8dda63ddd1abfba0eeaebec22f4142a0a206';

/// Device-local "already watched" markers (ring colour in the strip). Purely
/// a UI nicety, so it lives in preferences, not Postgres.

@ProviderFor(SeenPosts)
final seenPostsProvider = SeenPostsProvider._();

/// Device-local "already watched" markers (ring colour in the strip). Purely
/// a UI nicety, so it lives in preferences, not Postgres.
final class SeenPostsProvider
    extends $NotifierProvider<SeenPosts, Set<String>> {
  /// Device-local "already watched" markers (ring colour in the strip). Purely
  /// a UI nicety, so it lives in preferences, not Postgres.
  SeenPostsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'seenPostsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$seenPostsHash();

  @$internal
  @override
  SeenPosts create() => SeenPosts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$seenPostsHash() => r'7e4781699d350106c266db8fdba102c8451c69e4';

/// Device-local "already watched" markers (ring colour in the strip). Purely
/// a UI nicety, so it lives in preferences, not Postgres.

abstract class _$SeenPosts extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
