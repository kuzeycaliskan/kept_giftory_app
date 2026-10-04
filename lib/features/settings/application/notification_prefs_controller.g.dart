// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_prefs_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Applies notification-preference changes (G-63). Values are read from
/// [myProfileProvider]; a successful update refreshes it so every consumer
/// sees the new setting.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(NotificationPrefsController)
final notificationPrefsControllerProvider =
    NotificationPrefsControllerProvider._();

/// Applies notification-preference changes (G-63). Values are read from
/// [myProfileProvider]; a successful update refreshes it so every consumer
/// sees the new setting.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class NotificationPrefsControllerProvider
    extends $NotifierProvider<NotificationPrefsController, AsyncValue<void>> {
  /// Applies notification-preference changes (G-63). Values are read from
  /// [myProfileProvider]; a successful update refreshes it so every consumer
  /// sees the new setting.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  NotificationPrefsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPrefsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationPrefsControllerHash();

  @$internal
  @override
  NotificationPrefsController create() => NotificationPrefsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$notificationPrefsControllerHash() =>
    r'5c8b096a273ba5472d47d16ca0aa88215d31c463';

/// Applies notification-preference changes (G-63). Values are read from
/// [myProfileProvider]; a successful update refreshes it so every consumer
/// sees the new setting.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$NotificationPrefsController
    extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
