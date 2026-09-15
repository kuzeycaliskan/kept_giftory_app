import 'dart:typed_data';

import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';

/// In-app avatar crop (Instagram-style, pure Flutter — no native activity,
/// so no edge-to-edge/inset surprises). Circle mask, 1:1 locked; pops with
/// the cropped square bytes, or null when cancelled.
class AvatarCropScreen extends StatefulWidget {
  const AvatarCropScreen({required this.imageBytes, super.key});

  final Uint8List imageBytes;

  @override
  State<AvatarCropScreen> createState() => _AvatarCropScreenState();
}

class _AvatarCropScreenState extends State<AvatarCropScreen> {
  final _controller = CropController();
  var _cropping = false;

  void _onCropped(CropResult result) {
    if (!mounted) return;
    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.of(context).pop(croppedImage);
      case CropFailure(:final cause):
        debugPrint('avatar crop failed: $cause');
        setState(() => _cropping = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Back gesture/button is disabled here: edge pans while framing the
    // photo must never accidentally dismiss the screen. The close button
    // is the only cancel path (pops programmatically, so PopScope allows it).
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(l10n.avatarCropTitle),
          leading: CloseButton(
            onPressed: _cropping ? null : () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Crop(
                controller: _controller,
                image: widget.imageBytes,
                aspectRatio: 1,
                withCircleUi: true,
                baseColor: Colors.black,
                maskColor: Colors.black.withValues(alpha: 0.6),
                onCropped: _onCropped,
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _cropping
                        ? null
                        : () {
                            setState(() => _cropping = true);
                            _controller.crop();
                          },
                    child: _cropping
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.commonSave),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
