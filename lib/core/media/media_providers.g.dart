// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(mediaStore)
final mediaStoreProvider = MediaStoreProvider._();

final class MediaStoreProvider
    extends $FunctionalProvider<MediaStore, MediaStore, MediaStore>
    with $Provider<MediaStore> {
  MediaStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaStoreHash();

  @$internal
  @override
  $ProviderElement<MediaStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MediaStore create(Ref ref) {
    return mediaStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaStore>(value),
    );
  }
}

String _$mediaStoreHash() => r'359aa5e196d10933d703a3977ff02b78b2ef4715';

/// Platform image picker — gallery only since G-407; the camera is Kept's
/// own ([cameraBackend]).

@ProviderFor(imagePicker)
final imagePickerProvider = ImagePickerProvider._();

/// Platform image picker — gallery only since G-407; the camera is Kept's
/// own ([cameraBackend]).

final class ImagePickerProvider
    extends $FunctionalProvider<ImagePicker, ImagePicker, ImagePicker>
    with $Provider<ImagePicker> {
  /// Platform image picker — gallery only since G-407; the camera is Kept's
  /// own ([cameraBackend]).
  ImagePickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imagePickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imagePickerHash();

  @$internal
  @override
  $ProviderElement<ImagePicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImagePicker create(Ref ref) {
    return imagePicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImagePicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImagePicker>(value),
    );
  }
}

String _$imagePickerHash() => r'be60667b04027cd2a7d2e1b728a5c03b1bda8dc1';

/// The device camera (G-407); tests override it with a fake backend.

@ProviderFor(cameraBackend)
final cameraBackendProvider = CameraBackendProvider._();

/// The device camera (G-407); tests override it with a fake backend.

final class CameraBackendProvider
    extends $FunctionalProvider<CameraBackend, CameraBackend, CameraBackend>
    with $Provider<CameraBackend> {
  /// The device camera (G-407); tests override it with a fake backend.
  CameraBackendProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cameraBackendProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cameraBackendHash();

  @$internal
  @override
  $ProviderElement<CameraBackend> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CameraBackend create(Ref ref) {
    return cameraBackend(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CameraBackend value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CameraBackend>(value),
    );
  }
}

String _$cameraBackendHash() => r'f80f0ea33337eba5e54e6a6bfa2f62217dee11da';
