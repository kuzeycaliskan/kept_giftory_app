// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gift_photo_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$giftPhotoControllerHash() =>
    r'0cab20234ac5f4206de96626b34d470b925dfaf1';

/// Gift photo pipeline (G-204): camera-only capture, shared JPEG encoding,
/// attach/remove through the repository. Used by both log forms (photos
/// taken before the gift exists are attached right after it is created)
/// and the detail screen.
///
/// Copied from [GiftPhotoController].
@ProviderFor(GiftPhotoController)
final giftPhotoControllerProvider =
    AutoDisposeNotifierProvider<GiftPhotoController, AsyncValue<void>>.internal(
      GiftPhotoController.new,
      name: r'giftPhotoControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$giftPhotoControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GiftPhotoController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
