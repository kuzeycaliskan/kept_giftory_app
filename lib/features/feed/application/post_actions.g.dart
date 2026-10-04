// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_actions.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Actions on a live moment from the viewer: owner delete, viewer
/// reactions. Kept apart from the composer so the viewer doesn't drag the
/// capture pipeline in.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(PostActions)
final postActionsProvider = PostActionsProvider._();

/// Actions on a live moment from the viewer: owner delete, viewer
/// reactions. Kept apart from the composer so the viewer doesn't drag the
/// capture pipeline in.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class PostActionsProvider
    extends $NotifierProvider<PostActions, AsyncValue<void>> {
  /// Actions on a live moment from the viewer: owner delete, viewer
  /// reactions. Kept apart from the composer so the viewer doesn't drag the
  /// capture pipeline in.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  PostActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postActionsHash();

  @$internal
  @override
  PostActions create() => PostActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$postActionsHash() => r'1cd2ad36e32fcc54b02bb7c8705705f7216979c6';

/// Actions on a live moment from the viewer: owner delete, viewer
/// reactions. Kept apart from the composer so the viewer doesn't drag the
/// capture pipeline in.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$PostActions extends $Notifier<AsyncValue<void>> {
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
