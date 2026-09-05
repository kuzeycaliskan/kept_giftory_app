// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appRouterHash() => r'417cf93f6860aa4e6df876680658d0724e7ba3c6';

/// App navigation graph (G-81).
///
/// The router is created ONCE (keepAlive) — auth/dev-session changes tick a
/// [refreshListenable] instead of rebuilding the router, so navigation state
/// survives sign-in events (rebuilding used to reset to '/' and skip
/// onboarding).
///
/// Redirect rules:
///  * signed-out → only /sign-in;
///  * signed-in without a profile row → /onboarding (async check, cached by
///    myProfileProvider);
///  * signed-in with a profile → /sign-in and /onboarding bounce to '/'.
/// Backend-less runs (no --dart-define config) skip auth entirely.
///
/// Copied from [appRouter].
@ProviderFor(appRouter)
final appRouterProvider = Provider<GoRouter>.internal(
  appRouter,
  name: r'appRouterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appRouterHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppRouterRef = ProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
