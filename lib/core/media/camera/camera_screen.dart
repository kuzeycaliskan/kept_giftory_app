import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/media/camera/camera_backend.dart';
import 'package:kept/core/media/media_providers.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/shared/widgets/image_edit_screen.dart';

/// Opens Kept's viewfinder full-screen and returns the photo the user
/// chose to keep (orientation baked in), or null when they backed out.
/// Every camera entry in the app — moments, gift photos, avatar — comes
/// through here (G-407).
Future<Uint8List?> takePhoto(BuildContext context) {
  return Navigator.of(context, rootNavigator: true).push<Uint8List>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const CameraScreen(),
    ),
  );
}

/// The viewfinder (G-407): back/front lens, flash, shutter; then a still
/// to retake, edit (crop/rotate/mirror) or use. Black stage, white chrome,
/// like the story viewer. The lens is released whenever the app leaves the
/// foreground and reopened on return.
class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  List<CameraLens> _lenses = const [];
  CameraLens _lens = CameraLens.back;
  CameraFlash _flash = CameraFlash.off;
  CameraSession? _session;
  Uint8List? _shot;
  Object? _error;
  var _opening = false;
  var _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_open());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_session?.dispose());
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The plugin leaves lifecycle to us: hand the lens back while hidden.
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      unawaited(_close());
    } else if (state == AppLifecycleState.resumed && _shot == null) {
      unawaited(_open());
    }
  }

  Future<void> _close() async {
    final session = _session;
    if (session == null) return;
    setState(() => _session = null);
    await session.dispose();
  }

  Future<void> _open() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _error = null;
    });
    final backend = ref.read(cameraBackendProvider);
    try {
      if (_lenses.isEmpty) {
        _lenses = await backend.lenses();
        if (!_lenses.contains(_lens)) _lens = _lenses.first;
      }
      final session = await backend.open(_lens);
      await session.setFlash(_flash);
      if (!mounted) {
        await session.dispose();
        return;
      }
      setState(() => _session = session);
    } catch (e) {
      debugPrint('camera open failed: $e');
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  Future<void> _flip() async {
    final next = _lens == CameraLens.back ? CameraLens.front : CameraLens.back;
    if (!_lenses.contains(next)) return;
    await _close();
    _lens = next;
    await _open();
  }

  Future<void> _cycleFlash() async {
    final next = switch (_flash) {
      CameraFlash.off => CameraFlash.auto,
      CameraFlash.auto => CameraFlash.on,
      CameraFlash.on => CameraFlash.off,
    };
    setState(() => _flash = next);
    await _session?.setFlash(next);
  }

  Future<void> _shoot() async {
    final session = _session;
    if (session == null || _capturing) return;
    setState(() => _capturing = true);
    try {
      final bytes = await session.takePhoto();
      if (!mounted) return;
      setState(() => _shot = bytes);
      // Still shown: the lens can rest until a retake.
      await _close();
    } catch (e) {
      debugPrint('camera capture failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.errorGeneric)));
      }
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _retake() async {
    setState(() => _shot = null);
    await _open();
  }

  Future<void> _edit() async {
    final shot = _shot;
    if (shot == null) return;
    final edited = await Navigator.of(context).push<Uint8List>(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => ImageEditScreen(imageBytes: shot),
      ),
    );
    if (edited != null && mounted) setState(() => _shot = edited);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final shot = _shot;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: shot != null
            ? _Review(
                shot: shot,
                onRetake: _retake,
                onEdit: _edit,
                onUse: () => Navigator.of(context).pop(shot),
              )
            : _Viewfinder(
                session: _session,
                error: _error,
                flash: _flash,
                canFlip: _lenses.length > 1,
                busy: _opening || _capturing,
                onClose: () => Navigator.of(context).pop(),
                onFlash: _cycleFlash,
                onFlip: _flip,
                onShoot: _shoot,
                onRetry: _open,
                permissionCopy: l10n.cameraPermissionDenied,
                unavailableCopy: l10n.cameraUnavailable,
              ),
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder({
    required this.session,
    required this.error,
    required this.flash,
    required this.canFlip,
    required this.busy,
    required this.onClose,
    required this.onFlash,
    required this.onFlip,
    required this.onShoot,
    required this.onRetry,
    required this.permissionCopy,
    required this.unavailableCopy,
  });

  final CameraSession? session;
  final Object? error;
  final CameraFlash flash;
  final bool canFlip;
  final bool busy;
  final VoidCallback onClose;
  final VoidCallback onFlash;
  final VoidCallback onFlip;
  final VoidCallback onShoot;
  final VoidCallback onRetry;
  final String permissionCopy;
  final String unavailableCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final live = session;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (live != null)
          Center(child: live.preview())
        else if (error != null)
          _Trouble(
            message: error is CameraPermissionDenied
                ? permissionCopy
                : unavailableCopy,
            onRetry: onRetry,
          )
        else
          const Center(child: CircularProgressIndicator(color: Colors.white)),
        Align(
          alignment: Alignment.topCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
              IconButton(
                key: const Key('camera-flash'),
                tooltip: switch (flash) {
                  CameraFlash.off => l10n.cameraFlashOff,
                  CameraFlash.auto => l10n.cameraFlashAuto,
                  CameraFlash.on => l10n.cameraFlashOn,
                },
                icon: Icon(switch (flash) {
                  CameraFlash.off => Icons.flash_off,
                  CameraFlash.auto => Icons.flash_auto,
                  CameraFlash.on => Icons.flash_on,
                }, color: Colors.white),
                onPressed: live == null ? null : onFlash,
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: KeptSpacing.xl),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Keeps the shutter centred whether or not flip is shown.
                const SizedBox(width: 48),
                _Shutter(onTap: live == null || busy ? null : onShoot),
                SizedBox(
                  width: 48,
                  child: canFlip
                      ? IconButton(
                          key: const Key('camera-flip'),
                          tooltip: l10n.cameraFlip,
                          icon: const Icon(
                            Icons.cameraswitch_outlined,
                            color: Colors.white,
                          ),
                          onPressed: live == null || busy ? null : onFlip,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// The big round button: white ring, white disc.
class _Shutter extends StatelessWidget {
  const _Shutter({required this.onTap});

  final VoidCallback? onTap;

  static const double _size = 72;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.l10n.cameraShutter,
      child: InkWell(
        key: const Key('camera-shutter'),
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: _size,
          height: _size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          padding: const EdgeInsets.all(6),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: onTap == null ? Colors.white38 : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _Trouble extends StatelessWidget {
  const _Trouble({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(KeptSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.no_photography_outlined,
              color: Colors.white70,
              size: 40,
            ),
            const SizedBox(height: KeptSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: KeptSpacing.md),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              onPressed: onRetry,
              child: Text(context.l10n.cameraRetry),
            ),
          ],
        ),
      ),
    );
  }
}

/// The still, with the three ways on: retake, edit, use.
class _Review extends StatelessWidget {
  const _Review({
    required this.shot,
    required this.onRetake,
    required this.onEdit,
    required this.onUse,
  });

  final Uint8List shot;
  final VoidCallback onRetake;
  final VoidCallback onEdit;
  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Image.memory(
              shot,
              fit: BoxFit.contain,
              gaplessPlayback: true,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KeptSpacing.lg,
            KeptSpacing.md,
            KeptSpacing.lg,
            KeptSpacing.lg,
          ),
          child: Row(
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: onRetake,
                icon: const Icon(Icons.replay),
                label: Text(l10n.cameraRetake),
              ),
              const Spacer(),
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                onPressed: onEdit,
                icon: const Icon(Icons.crop_rotate),
                label: Text(l10n.cameraEdit),
              ),
              const SizedBox(width: KeptSpacing.sm),
              FilledButton(onPressed: onUse, child: Text(l10n.cameraUse)),
            ],
          ),
        ),
      ],
    );
  }
}
