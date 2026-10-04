// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Debug-only auth bypass so screens behind the sign-in wall can be tested
/// before the OAuth providers are configured (G-11 pending).
///
/// Guarded by [kDebugMode]: in release builds [enable] is a no-op, so this
/// can never leak into a store build. Real sign-in is verified (Apple +
/// Google, 2026-09-05); kept as a dev tool for backend-less UI iteration.

@ProviderFor(DevSession)
final devSessionProvider = DevSessionProvider._();

/// Debug-only auth bypass so screens behind the sign-in wall can be tested
/// before the OAuth providers are configured (G-11 pending).
///
/// Guarded by [kDebugMode]: in release builds [enable] is a no-op, so this
/// can never leak into a store build. Real sign-in is verified (Apple +
/// Google, 2026-09-05); kept as a dev tool for backend-less UI iteration.
final class DevSessionProvider extends $NotifierProvider<DevSession, bool> {
  /// Debug-only auth bypass so screens behind the sign-in wall can be tested
  /// before the OAuth providers are configured (G-11 pending).
  ///
  /// Guarded by [kDebugMode]: in release builds [enable] is a no-op, so this
  /// can never leak into a store build. Real sign-in is verified (Apple +
  /// Google, 2026-09-05); kept as a dev tool for backend-less UI iteration.
  DevSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'devSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$devSessionHash();

  @$internal
  @override
  DevSession create() => DevSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$devSessionHash() => r'36bc79e8f2b2f315d37538b366ad339f257bebd8';

/// Debug-only auth bypass so screens behind the sign-in wall can be tested
/// before the OAuth providers are configured (G-11 pending).
///
/// Guarded by [kDebugMode]: in release builds [enable] is a no-op, so this
/// can never leak into a store build. Real sign-in is verified (Apple +
/// Google, 2026-09-05); kept as a dev tool for backend-less UI iteration.

abstract class _$DevSession extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
