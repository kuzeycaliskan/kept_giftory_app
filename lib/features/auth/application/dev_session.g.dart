// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dev_session.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$devSessionHash() => r'36bc79e8f2b2f315d37538b366ad339f257bebd8';

/// Debug-only auth bypass so screens behind the sign-in wall can be tested
/// before the OAuth providers are configured (G-11 pending).
///
/// Guarded by [kDebugMode]: in release builds [enable] is a no-op, so this
/// can never leak into a store build. Real sign-in is verified (Apple +
/// Google, 2026-09-05); kept as a dev tool for backend-less UI iteration.
///
/// Copied from [DevSession].
@ProviderFor(DevSession)
final devSessionProvider = NotifierProvider<DevSession, bool>.internal(
  DevSession.new,
  name: r'devSessionProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$devSessionHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$DevSession = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
