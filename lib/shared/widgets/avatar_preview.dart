import 'package:flutter/material.dart';

/// Full-screen avatar preview (Instagram-style): dark backdrop, pinch-zoom,
/// tap outside or the close button to dismiss.
Future<void> showAvatarPreview(
  BuildContext context, {
  required String url,
  required String label,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).closeButtonLabel,
    barrierColor: Colors.black87,
    pageBuilder: (context, _, __) => _AvatarPreview(url: url, label: label),
    transitionDuration: const Duration(milliseconds: 150),
    transitionBuilder: (context, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}

class _AvatarPreview extends StatelessWidget {
  const _AvatarPreview({required this.url, required this.label});

  final String url;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: CloseButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Center(
          child: InteractiveViewer(
            maxScale: 4,
            child: Image.network(
              url,
              semanticLabel: label,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
              errorBuilder: (context, error, stack) => const Icon(
                Icons.person_outline,
                size: 96,
                color: Colors.white54,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
