import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/feed/application/post_composer.dart';

/// Route of the compose screen; the captured bytes travel as `extra`, an
/// unboxing's gift as `?gift=<id>&item=<label>` (G-308).
const String composePostRoute = '/posts/new';

/// The gift an unboxing moment is about: what the compose screen shows and
/// what the post links to.
@immutable
class UnboxingTarget {
  const UnboxingTarget({required this.giftId, required this.item});

  final String giftId;
  final String item;

  String get route =>
      '$composePostRoute?gift=$giftId&item=${Uri.encodeQueryComponent(item)}';
}

/// Shared entry point for "take a moment" (G-201): the ➕ tab and the strip's
/// camera ring both land here; the gift detail passes [unboxing] (G-308).
/// Opens the camera, then the compose screen. Backing out of the camera is
/// silent; a platform failure gets one snack.
Future<void> captureMoment(
  BuildContext context,
  WidgetRef ref, {
  UnboxingTarget? unboxing,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);
  final l10n = context.l10n;
  try {
    final bytes = await ref.read(postComposerProvider.notifier).capture();
    if (bytes == null) return;
    await router.push(unboxing?.route ?? composePostRoute, extra: bytes);
  } catch (e) {
    debugPrint('moment capture failed: $e');
    messenger.showSnackBar(SnackBar(content: Text(l10n.cameraUnavailable)));
  }
}
