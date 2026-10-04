// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_composer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Capture → share pipeline for a moment (G-201). Two steps so the compose
/// screen sits between them: [capture] opens the device camera (never the
/// gallery — a moment is taken now), [publish] shrinks + stores.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(PostComposer)
final postComposerProvider = PostComposerProvider._();

/// Capture → share pipeline for a moment (G-201). Two steps so the compose
/// screen sits between them: [capture] opens the device camera (never the
/// gallery — a moment is taken now), [publish] shrinks + stores.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class PostComposerProvider
    extends $NotifierProvider<PostComposer, AsyncValue<void>> {
  /// Capture → share pipeline for a moment (G-201). Two steps so the compose
  /// screen sits between them: [capture] opens the device camera (never the
  /// gallery — a moment is taken now), [publish] shrinks + stores.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  PostComposerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postComposerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postComposerHash();

  @$internal
  @override
  PostComposer create() => PostComposer();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$postComposerHash() => r'499de18d5ba222444ae71d8ccefe6dcc4fdd54cc';

/// Capture → share pipeline for a moment (G-201). Two steps so the compose
/// screen sits between them: [capture] opens the device camera (never the
/// gallery — a moment is taken now), [publish] shrinks + stores.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$PostComposer extends $Notifier<AsyncValue<void>> {
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
