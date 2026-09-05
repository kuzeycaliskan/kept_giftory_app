import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dev_session.g.dart';

/// Debug-only auth bypass so screens behind the sign-in wall can be tested
/// before the OAuth providers are configured (G-11 pending).
///
/// Guarded by [kDebugMode]: in release builds [enable] is a no-op, so this
/// can never leak into a store build. Real sign-in is verified (Apple +
/// Google, 2026-09-05); kept as a dev tool for backend-less UI iteration.
@Riverpod(keepAlive: true)
class DevSession extends _$DevSession {
  @override
  bool build() => false;

  void enable() {
    if (kDebugMode) state = true;
  }
}
