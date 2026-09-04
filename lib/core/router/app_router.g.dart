// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appRouterHash() => r'905d77e7587fbb1aad00b3085c6c49ec22e72bf2';

/// App navigation graph. The V1 tab shell (Home / Gifts / Add / Me) lands with
/// G-81; for now: sign-in → onboarding → home.
///
/// Redirect rule: signed-out users can only see /sign-in. Whether onboarding
/// is complete (profile row exists) is decided post-sign-in by the flow itself.
/// Backend-less runs (no --dart-define config) skip auth entirely so the app
/// stays runnable in early dev.
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
