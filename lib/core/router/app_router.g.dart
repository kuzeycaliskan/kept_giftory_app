// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appRouterHash() => r'48b1f76bc74a0ea31eaefc96706be0bf6ff501c7';

/// App navigation graph (G-81).
///
/// Tab shell (Home / Gifts / Me as stateful branches; ➕ Add is an action, not
/// a branch) + full-screen routes above the shell (sign-in, onboarding,
/// activity, quick-add targets).
///
/// Redirect rule: signed-out users can only see /sign-in. Whether onboarding
/// is complete (profile row exists) is decided post-sign-in by the flow
/// itself. Backend-less runs (no --dart-define config) skip auth entirely so
/// the app stays runnable in early dev.
///
/// Copied from [appRouter].
@ProviderFor(appRouter)
final appRouterProvider = AutoDisposeProvider<GoRouter>.internal(
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
typedef AppRouterRef = AutoDisposeProviderRef<GoRouter>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
