import 'package:crop_your_image/crop_your_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/media/image_encoding.dart';
import 'package:kept/core/theme/kept_tokens.dart';

/// Crop + rotate + mirror before saving a photo (pure Flutter — no native
/// activity, so no edge-to-edge/inset surprises). Pops with the edited
/// bytes, or null when cancelled. Rotate/mirror rewrite the working copy
/// off the UI thread and reload the cropper; nothing is applied unless the
/// user asks (a front-camera shot is never mirrored by default — the
/// caller normalises EXIF first).
class ImageEditScreen extends StatefulWidget {
  const ImageEditScreen({
    required this.imageBytes,
    this.aspectRatio,
    this.circle = false,
    super.key,
  });

  final Uint8List imageBytes;

  /// Locked ratio (1 for avatars); null = free crop.
  final double? aspectRatio;

  /// Circular mask (avatars).
  final bool circle;

  @override
  State<ImageEditScreen> createState() => _ImageEditScreenState();
}

class _ImageEditScreenState extends State<ImageEditScreen> {
  final _controller = CropController();
  late Uint8List _bytes = widget.imageBytes;

  /// Bumped on every rewrite so the cropper re-decodes the new bytes.
  var _revision = 0;
  var _busy = false;

  Future<void> _transform(Uint8List Function(Uint8List) op) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final next = await compute(op, _bytes);
      if (!mounted) return;
      setState(() {
        _bytes = next;
        _revision++;
      });
    } catch (e) {
      debugPrint('image edit failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _onCropped(CropResult result) {
    if (!mounted) return;
    switch (result) {
      case CropSuccess(:final croppedImage):
        Navigator.of(context).pop(croppedImage);
      case CropFailure(:final cause):
        debugPrint('image crop failed: $cause');
        setState(() => _busy = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
    }
  }

  void _save() {
    setState(() => _busy = true);
    _controller.crop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Back gesture/button is disabled: edge pans while framing must never
    // dismiss the screen. The close button is the only cancel path.
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(l10n.avatarCropTitle),
          leading: CloseButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Crop(
                key: ValueKey(_revision),
                controller: _controller,
                image: _bytes,
                aspectRatio: widget.aspectRatio,
                withCircleUi: widget.circle,
                baseColor: Colors.black,
                maskColor: Colors.black.withValues(alpha: 0.6),
                onCropped: _onCropped,
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(KeptSpacing.lg),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _EditAction(
                          icon: Icons.rotate_90_degrees_cw_outlined,
                          label: l10n.imageEditRotate,
                          onTap: _busy
                              ? null
                              : () => _transform(rotateQuarterTurn),
                        ),
                        const SizedBox(width: KeptSpacing.xl),
                        _EditAction(
                          icon: Icons.flip_outlined,
                          label: l10n.imageEditMirror,
                          onTap: _busy
                              ? null
                              : () => _transform(flipHorizontal),
                        ),
                      ],
                    ),
                    const SizedBox(height: KeptSpacing.md),
                    FilledButton(
                      onPressed: _busy ? null : _save,
                      child: _busy
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.commonSave),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon + label action on the dark editor stage (white chrome, same
/// exception as the other full-screen photo surfaces).
class _EditAction extends StatelessWidget {
  const _EditAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = onTap == null ? Colors.white38 : Colors.white;
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: KeptRadius.controlAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KeptSpacing.md,
            vertical: KeptSpacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: KeptSpacing.xs),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
