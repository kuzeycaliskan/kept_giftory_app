// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Avatar pipeline (G-23 handover; first MediaStore consumer), split in two
/// steps so the UI can host the in-app crop screen between them:
/// [pickImage] → (AvatarCropScreen) → [uploadCropped]. Path layout
/// `<uid>/avatar-<epoch>.jpg` gives free cache-busting; the previous file
/// is best-effort deleted after success.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(AvatarController)
final avatarControllerProvider = AvatarControllerProvider._();

/// Avatar pipeline (G-23 handover; first MediaStore consumer), split in two
/// steps so the UI can host the in-app crop screen between them:
/// [pickImage] → (AvatarCropScreen) → [uploadCropped]. Path layout
/// `<uid>/avatar-<epoch>.jpg` gives free cache-busting; the previous file
/// is best-effort deleted after success.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class AvatarControllerProvider
    extends $NotifierProvider<AvatarController, AsyncValue<void>> {
  /// Avatar pipeline (G-23 handover; first MediaStore consumer), split in two
  /// steps so the UI can host the in-app crop screen between them:
  /// [pickImage] → (AvatarCropScreen) → [uploadCropped]. Path layout
  /// `<uid>/avatar-<epoch>.jpg` gives free cache-busting; the previous file
  /// is best-effort deleted after success.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  AvatarControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'avatarControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$avatarControllerHash();

  @$internal
  @override
  AvatarController create() => AvatarController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$avatarControllerHash() => r'6d563e9b727bb81822c5085882fd9a96791e508a';

/// Avatar pipeline (G-23 handover; first MediaStore consumer), split in two
/// steps so the UI can host the in-app crop screen between them:
/// [pickImage] → (AvatarCropScreen) → [uploadCropped]. Path layout
/// `<uid>/avatar-<epoch>.jpg` gives free cache-busting; the previous file
/// is best-effort deleted after success.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$AvatarController extends $Notifier<AsyncValue<void>> {
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
