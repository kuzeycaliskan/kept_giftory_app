// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_encoding.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$uploadEncoderHash() => r'415d658ddeb6b972ef2ee70bc1038e57c412f93c';

/// Bytes-in → upload JPEG-out, off the UI thread. A provider so widget
/// tests can skip the isolate hop (`compute` and fake async don't mix).
///
/// Copied from [uploadEncoder].
@ProviderFor(uploadEncoder)
final uploadEncoderProvider =
    Provider<Future<Uint8List> Function(Uint8List)>.internal(
      uploadEncoder,
      name: r'uploadEncoderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$uploadEncoderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UploadEncoderRef = ProviderRef<Future<Uint8List> Function(Uint8List)>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
