import 'package:flutter/material.dart';
import 'package:kept/core/theme/kept_tokens.dart';

/// Grouped list (design.md §4): rows inside one hairline-bordered container,
/// separated by hairline dividers. Gives dashboard sections a shared edge so
/// rows, avatars and icons line up with each other instead of floating.
/// Standalone full-screen lists stay flat rows; this is for sections.
class KeptListGroup extends StatelessWidget {
  const KeptListGroup({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: KeptRadius.cardAll,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Leading slot for icon rows: the icon sits in a 40dp tinted circle so it
/// occupies the same footprint as a [CircleAvatar] of radius 20 — icon rows
/// and avatar rows in the same group share one text column.
class KeptIconBadge extends StatelessWidget {
  const KeptIconBadge(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 20,
      backgroundColor: scheme.surfaceContainerHighest,
      child: Icon(icon, size: 20, color: scheme.onSurfaceVariant),
    );
  }
}
