// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$avatarControllerHash() => r'b46c7da418341d446f0c58b44b39bf89a53559f0';

/// Avatar pipeline (G-23 handover; first MediaStore consumer), split in two
/// steps so the UI can host the in-app crop screen between them:
/// [pickImage] → (AvatarCropScreen) → [uploadCropped]. Path layout
/// '<uid>/avatar-<epoch>.jpg' gives free cache-busting; the previous file
/// is best-effort deleted after success.
///
/// Copied from [AvatarController].
@ProviderFor(AvatarController)
final avatarControllerProvider =
    AutoDisposeNotifierProvider<AvatarController, AsyncValue<void>>.internal(
      AvatarController.new,
      name: r'avatarControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$avatarControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AvatarController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
