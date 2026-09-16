import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/feed/application/post_composer.dart';

/// Route of the compose screen; the captured bytes travel as `extra`.
const String composePostRoute = '/posts/new';

/// Shared entry point for "take a moment" (G-201): the ➕ tab and the strip's
/// camera ring both land here. Opens the camera, then the compose screen.
/// Backing out of the camera is silent; a platform failure gets one snack.
Future<void> captureMoment(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final l10n = context.l10n;
  try {
    final bytes = await ref.read(postComposerProvider.notifier).capture();
    if (bytes == null) return;
    await router.push(composePostRoute, extra: bytes);
  } catch (e) {
    debugPrint('moment capture failed: $e');
    messenger.showSnackBar(SnackBar(content: Text(l10n.cameraUnavailable)));
  }
}
