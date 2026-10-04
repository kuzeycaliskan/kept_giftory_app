// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Applies section-visibility changes (G-22). The screen reads current values
/// from [myProfileProvider]; this controller only performs the mutation and
/// refreshes that provider so every consumer sees the new setting at once.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

@ProviderFor(PrivacySettingsController)
final privacySettingsControllerProvider = PrivacySettingsControllerProvider._();

/// Applies section-visibility changes (G-22). The screen reads current values
/// from [myProfileProvider]; this controller only performs the mutation and
/// refreshes that provider so every consumer sees the new setting at once.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
final class PrivacySettingsControllerProvider
    extends $NotifierProvider<PrivacySettingsController, AsyncValue<void>> {
  /// Applies section-visibility changes (G-22). The screen reads current values
  /// from [myProfileProvider]; this controller only performs the mutation and
  /// refreshes that provider so every consumer sees the new setting at once.
  // Action controller: kept alive so a call that outlives its screen can
  // still refresh the lists it touched (Riverpod 3 throws on a disposed ref).
  PrivacySettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privacySettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privacySettingsControllerHash();

  @$internal
  @override
  PrivacySettingsController create() => PrivacySettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$privacySettingsControllerHash() =>
    r'4195226a59cb4083fafe491969603ccf0c310a72';

/// Applies section-visibility changes (G-22). The screen reads current values
/// from [myProfileProvider]; this controller only performs the mutation and
/// refreshes that provider so every consumer sees the new setting at once.
// Action controller: kept alive so a call that outlives its screen can
// still refresh the lists it touched (Riverpod 3 throws on a disposed ref).

abstract class _$PrivacySettingsController extends $Notifier<AsyncValue<void>> {
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
