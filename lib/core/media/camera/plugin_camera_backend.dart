import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:kept/core/media/camera/camera_backend.dart';
import 'package:kept/core/media/image_encoding.dart';

/// [CameraBackend] over the `camera` plugin (CameraX on Android, AVFoundation
/// on iOS). Stills only: no audio session, so no microphone prompt.
class PluginCameraBackend implements CameraBackend {
  const PluginCameraBackend();

  @override
  Future<List<CameraLens>> lenses() async {
    final List<CameraDescription> found;
    try {
      found = await availableCameras();
    } on CameraException catch (e) {
      throw CameraUnavailable(e.description ?? e.code);
    }
    final lenses = <CameraLens>[
      if (found.any((c) => c.lensDirection == CameraLensDirection.back))
        CameraLens.back,
      if (found.any((c) => c.lensDirection == CameraLensDirection.front))
        CameraLens.front,
    ];
    if (lenses.isEmpty) throw const CameraUnavailable('no lens');
    return lenses;
  }

  @override
  Future<CameraSession> open(CameraLens lens) async {
    final wanted = lens == CameraLens.front
        ? CameraLensDirection.front
        : CameraLensDirection.back;
    final List<CameraDescription> found;
    try {
      found = await availableCameras();
    } on CameraException catch (e) {
      throw CameraUnavailable(e.description ?? e.code);
    }
    final description = found
        .where((c) => c.lensDirection == wanted)
        .firstOrNull;
    if (description == null) throw CameraUnavailable('no $lens lens');
    final controller = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    try {
      await controller.initialize();
      // Stills are portrait in Kept; locking stops a mid-shot rotation from
      // handing us a sideways frame.
      await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
    } on CameraException catch (e) {
      await controller.dispose();
      if (_isPermissionError(e)) throw const CameraPermissionDenied();
      throw CameraUnavailable(e.description ?? e.code);
    }
    return _PluginSession(lens, controller);
  }

  static bool _isPermissionError(CameraException e) {
    final code = e.code.toLowerCase();
    return code.contains('denied') || code.contains('permission');
  }
}

class _PluginSession implements CameraSession {
  _PluginSession(this.lens, this._controller);

  @override
  final CameraLens lens;
  final CameraController _controller;

  @override
  Widget preview() => CameraPreview(_controller);

  @override
  Future<void> setFlash(CameraFlash mode) =>
      _controller.setFlashMode(switch (mode) {
        CameraFlash.off => FlashMode.off,
        CameraFlash.auto => FlashMode.auto,
        CameraFlash.on => FlashMode.always,
      });

  @override
  Future<Uint8List> takePhoto() async {
    final file = await _controller.takePicture();
    final raw = await file.readAsBytes();
    // The plugin writes the EXIF orientation tag rather than rotating
    // pixels; downstream croppers work on pixels, so bake it in now.
    return compute(normalizeOrientation, raw);
  }

  @override
  Future<void> dispose() => _controller.dispose();
}
