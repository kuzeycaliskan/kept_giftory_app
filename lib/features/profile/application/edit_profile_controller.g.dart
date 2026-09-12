// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'edit_profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$editProfileControllerHash() =>
    r'5943ee40bc7de8da2996ac886d8615735ff4a0ac';

/// Saves profile edits (G-23). Success refreshes [myProfileProvider] so the
/// Me screen and every other consumer re-render at once.
///
/// Copied from [EditProfileController].
@ProviderFor(EditProfileController)
final editProfileControllerProvider =
    AutoDisposeNotifierProvider<
      EditProfileController,
      AsyncValue<void>
    >.internal(
      EditProfileController.new,
      name: r'editProfileControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$editProfileControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$EditProfileController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
