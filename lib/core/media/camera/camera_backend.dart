import 'dart:typed_data';

import 'package:flutter/widgets.dart';

/// Which way a lens points.
enum CameraLens { back, front }

/// Flash behaviour for the next shot.
enum CameraFlash { off, auto, on }

/// The device camera behind an interface (G-407): the viewfinder screen
/// talks to this, the plugin-backed implementation lives in data, and
/// tests hand the screen a fake with a canned shot.
abstract interface class CameraBackend {
  /// Lenses the device offers, back first. Throws [CameraUnavailable] when
  /// there is none (emulator without a virtual camera, broken hardware).
  Future<List<CameraLens>> lenses();

  /// Opens one lens; the session owns the hardware until
  /// [CameraSession.dispose].
  /// Throws [CameraPermissionDenied] when the user refused access.
  Future<CameraSession> open(CameraLens lens);
}

/// A live lens: preview, flash, one still at a time.
abstract interface class CameraSession {
  CameraLens get lens;

  /// The live viewfinder, sized by its parent.
  Widget preview();

  Future<void> setFlash(CameraFlash mode);

  /// A JPEG with its orientation baked in, as the user framed it.
  Future<Uint8List> takePhoto();

  Future<void> dispose();
}

class CameraPermissionDenied implements Exception {
  const CameraPermissionDenied();
}

class CameraUnavailable implements Exception {
  const CameraUnavailable(this.reason);

  final String reason;

  @override
  String toString() => 'CameraUnavailable: $reason';
}
