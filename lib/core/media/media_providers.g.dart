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

/// Platform image picker behind a provider so tests can hand screens a
/// fake camera.

@ProviderFor(imagePicker)
final imagePickerProvider = ImagePickerProvider._();

/// Platform image picker behind a provider so tests can hand screens a
/// fake camera.

final class ImagePickerProvider
    extends $FunctionalProvider<ImagePicker, ImagePicker, ImagePicker>
    with $Provider<ImagePicker> {
  /// Platform image picker behind a provider so tests can hand screens a
  /// fake camera.
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
