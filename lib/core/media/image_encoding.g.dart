// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_encoding.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Bytes-in → upload JPEG-out, off the UI thread. A provider so widget
/// tests can skip the isolate hop (`compute` and fake async don't mix).

@ProviderFor(uploadEncoder)
final uploadEncoderProvider = UploadEncoderProvider._();

/// Bytes-in → upload JPEG-out, off the UI thread. A provider so widget
/// tests can skip the isolate hop (`compute` and fake async don't mix).

final class UploadEncoderProvider
    extends
        $FunctionalProvider<
          Future<Uint8List> Function(Uint8List),
          Future<Uint8List> Function(Uint8List),
          Future<Uint8List> Function(Uint8List)
        >
    with $Provider<Future<Uint8List> Function(Uint8List)> {
  /// Bytes-in → upload JPEG-out, off the UI thread. A provider so widget
  /// tests can skip the isolate hop (`compute` and fake async don't mix).
  UploadEncoderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadEncoderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadEncoderHash();

  @$internal
  @override
  $ProviderElement<Future<Uint8List> Function(Uint8List)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Future<Uint8List> Function(Uint8List) create(Ref ref) {
    return uploadEncoder(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Future<Uint8List> Function(Uint8List) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<Future<Uint8List> Function(Uint8List)>(value),
    );
  }
}

String _$uploadEncoderHash() => r'415d658ddeb6b972ef2ee70bc1038e57c412f93c';
