// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_photo_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Gift photo pipeline (G-204): camera-only capture, shared JPEG encoding,
/// attach/remove through the repository. Used by both log forms (photos
/// taken before the gift exists are attached right after it is created)
/// and the detail screen.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(GiftPhotoController)
final giftPhotoControllerProvider = GiftPhotoControllerProvider._();

/// Gift photo pipeline (G-204): camera-only capture, shared JPEG encoding,
/// attach/remove through the repository. Used by both log forms (photos
/// taken before the gift exists are attached right after it is created)
/// and the detail screen.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class GiftPhotoControllerProvider
    extends $NotifierProvider<GiftPhotoController, AsyncValue<void>> {
  /// Gift photo pipeline (G-204): camera-only capture, shared JPEG encoding,
  /// attach/remove through the repository. Used by both log forms (photos
  /// taken before the gift exists are attached right after it is created)
  /// and the detail screen.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  GiftPhotoControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'giftPhotoControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$giftPhotoControllerHash();

  @$internal
  @override
  GiftPhotoController create() => GiftPhotoController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$giftPhotoControllerHash() =>
    r'eba3b725ad466e874f167caa154dbf649f2fdc7d';

/// Gift photo pipeline (G-204): camera-only capture, shared JPEG encoding,
/// attach/remove through the repository. Used by both log forms (photos
/// taken before the gift exists are attached right after it is created)
/// and the detail screen.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$GiftPhotoController extends $Notifier<AsyncValue<void>> {
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
