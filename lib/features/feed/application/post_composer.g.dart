// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_composer.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$postComposerHash() => r'be8ce67facaa909407455dc293aa955c89705553';

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
