import 'package:flutter/material.dart';
import 'package:kept/core/theme/kept_tokens.dart';

/// Section title above a group or block (design.md §4): titleMedium, a
/// hair of left inset to align with grouped-list text, fixed gap below so
/// every section reads header → content with the same rhythm.
class KeptSectionHeader extends StatelessWidget {
  const KeptSectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: KeptSpacing.xs,
        bottom: KeptSpacing.sm,
      ),
      child: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
