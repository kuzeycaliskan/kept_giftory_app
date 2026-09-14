// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'avatar_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$avatarControllerHash() => r'71c081a2e2732dcbca28669ecd8b9237adcc3e0a';

/// Picks, shrinks and uploads the user's avatar (G-23 handover; first
/// MediaStore consumer). Path layout '<uid>/avatar-<epoch>.jpg' gives free
/// cache-busting; the previous file is best-effort deleted after success.
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
