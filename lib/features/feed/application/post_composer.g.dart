// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_composer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postEncoderHash() => r'b9ee9453a48fc63ae64ece12c95e88e880bb6192';

/// Bytes-in → post JPEG-out. A provider so widget tests can skip the isolate
/// hop (`compute` and fake async don't mix) with an identity encoder.
///
/// Copied from [postEncoder].
@ProviderFor(postEncoder)
final postEncoderProvider =
    Provider<Future<Uint8List> Function(Uint8List)>.internal(
      postEncoder,
      name: r'postEncoderProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$postEncoderHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PostEncoderRef = ProviderRef<Future<Uint8List> Function(Uint8List)>;
String _$postComposerHash() => r'91a88983654c45ef49e909c9d8b2faa4727aeb10';

/// Capture → share pipeline for a moment (G-201). Two steps so the compose
/// screen sits between them: [capture] opens the device camera (never the
/// gallery — a moment is taken now), [publish] shrinks + stores.
///
/// Copied from [PostComposer].
@ProviderFor(PostComposer)
final postComposerProvider =
    AutoDisposeNotifierProvider<PostComposer, AsyncValue<void>>.internal(
      PostComposer.new,
      name: r'postComposerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$postComposerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PostComposer = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
