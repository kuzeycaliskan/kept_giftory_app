// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_prefs_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$notificationPrefsControllerHash() =>
    r'76ebbce095ec2b81fed46db776647e2e7266a85d';

/// Applies notification-preference changes (G-63). Values are read from
/// [myProfileProvider]; a successful update refreshes it so every consumer
/// sees the new setting.
///
/// Copied from [NotificationPrefsController].
@ProviderFor(NotificationPrefsController)
final notificationPrefsControllerProvider =
    AutoDisposeNotifierProvider<
      NotificationPrefsController,
      AsyncValue<void>
    >.internal(
      NotificationPrefsController.new,
      name: r'notificationPrefsControllerProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$notificationPrefsControllerHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$NotificationPrefsController = AutoDisposeNotifier<AsyncValue<void>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
