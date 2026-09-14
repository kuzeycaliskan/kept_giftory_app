import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/media/media_providers.dart';

/// House avatar (design.md §4): circle photo with initial fallback in
/// primaryContainer/primary. Resolves stored paths through MediaStore so
/// callers never build URLs themselves.
class KeptAvatar extends ConsumerWidget {
  const KeptAvatar({
    required this.label,
    this.avatarValue,
    this.radius = 20,
    super.key,
  });

  /// Display name/username — first character becomes the fallback initial.
  final String label;

  /// Stored avatar path (or legacy full URL); null = initial fallback.
  final String? avatarValue;

  final double radius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Touch MediaStore only for real stored paths — null/full-URL values
    // must not require a Supabase instance (widget tests, dev data).
    final value = avatarValue;
    final String? url;
    if (value == null || value.isEmpty) {
      url = null;
    } else if (value.startsWith('http')) {
      url = value;
    } else {
      url = avatarDisplayUrl(ref.watch(mediaStoreProvider), value);
    }
    final initial = label.isEmpty ? '?' : label.characters.first.toUpperCase();
    return CircleAvatar(
      radius: radius,
      foregroundImage: url == null ? null : NetworkImage(url),
      child: Text(
        initial,
        style: TextStyle(fontSize: radius * 0.9, fontWeight: FontWeight.w600),
      ),
    );
  }
}
