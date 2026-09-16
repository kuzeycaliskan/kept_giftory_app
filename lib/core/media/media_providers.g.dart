// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$mediaStoreHash() => r'359aa5e196d10933d703a3977ff02b78b2ef4715';

/// See also [mediaStore].
@ProviderFor(mediaStore)
final mediaStoreProvider = Provider<MediaStore>.internal(
  mediaStore,
  name: r'mediaStoreProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mediaStoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef MediaStoreRef = ProviderRef<MediaStore>;
String _$imagePickerHash() => r'be60667b04027cd2a7d2e1b728a5c03b1bda8dc1';

/// Platform image picker behind a provider so tests can hand screens a
/// fake camera.
///
/// Copied from [imagePicker].
@ProviderFor(imagePicker)
final imagePickerProvider = Provider<ImagePicker>.internal(
  imagePicker,
  name: r'imagePickerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$imagePickerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ImagePickerRef = ProviderRef<ImagePicker>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
