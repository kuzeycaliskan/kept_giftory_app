// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friends_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(friendshipRepository)
final friendshipRepositoryProvider = FriendshipRepositoryProvider._();

final class FriendshipRepositoryProvider
    extends
        $FunctionalProvider<
          FriendshipRepository,
          FriendshipRepository,
          FriendshipRepository
        >
    with $Provider<FriendshipRepository> {
  FriendshipRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendshipRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendshipRepositoryHash();

  @$internal
  @override
  $ProviderElement<FriendshipRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FriendshipRepository create(Ref ref) {
    return friendshipRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FriendshipRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FriendshipRepository>(value),
    );
  }
}

String _$friendshipRepositoryHash() =>
    r'5f9d002d4865060b9a87b2d91c2652949d7f17b9';

/// All friendship rows for the Friends screen (friends + pending requests).

@ProviderFor(friendEntries)
final friendEntriesProvider = FriendEntriesProvider._();

/// All friendship rows for the Friends screen (friends + pending requests).

final class FriendEntriesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<FriendEntry>>,
          List<FriendEntry>,
          FutureOr<List<FriendEntry>>
        >
    with
        $FutureModifier<List<FriendEntry>>,
        $FutureProvider<List<FriendEntry>> {
  /// All friendship rows for the Friends screen (friends + pending requests).
  FriendEntriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendEntriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendEntriesHash();

  @$internal
  @override
  $FutureProviderElement<List<FriendEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<FriendEntry>> create(Ref ref) {
    return friendEntries(ref);
  }
}

String _$friendEntriesHash() => r'a17dfc8eb340908e84fbd8ad14e4cab358bdac60';

/// Mutations for the Friends screen; refreshes the list on success.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(FriendsController)
final friendsControllerProvider = FriendsControllerProvider._();

/// Mutations for the Friends screen; refreshes the list on success.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class FriendsControllerProvider
    extends $NotifierProvider<FriendsController, AsyncValue<void>> {
  /// Mutations for the Friends screen; refreshes the list on success.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  FriendsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendsControllerHash();

  @$internal
  @override
  FriendsController create() => FriendsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$friendsControllerHash() => r'daa4e879f5bc79df90a2be278880cafb320f7522';

/// Mutations for the Friends screen; refreshes the list on success.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$FriendsController extends $Notifier<AsyncValue<void>> {
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
