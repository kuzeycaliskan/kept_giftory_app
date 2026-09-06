// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$privacySettingsControllerHash() =>
    r'14d37b06ed39e2aa368d7fde657dd3ea47b927b6';

/// Applies section-visibility changes (G-22). The screen reads current values
/// from [myProfileProvider]; this controller only performs the mutation and
/// refreshes that provider so every consumer sees the new setting at once.
///
/// Copied from [PrivacySettingsController].
@ProviderFor(PrivacySettingsController)
final privacySettingsControllerProvider =
    AutoDisposeNotifierProvider<
      PrivacySettingsController,
      AsyncValue<void>
    >.internal(
      PrivacySettingsController.new,
      name: r'privacySettingsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$privacySettingsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PrivacySettingsController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
