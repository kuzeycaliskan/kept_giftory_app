import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/features/link_preview/application/link_preview_providers.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/shared/widgets/link_preview_card.dart';

/// URL input with debounced product-preview fetching (G-211): pasting a
/// link shows a dismissible [LinkPreviewCard] under the field. Every failure
/// collapses silently to free text — the surrounding form never blocks.
///
/// The parent owns [controller]; the attached preview is reported through
/// [onPreviewChanged] (null when absent/dismissed).
class LinkPreviewField extends ConsumerStatefulWidget {
  const LinkPreviewField({
    required this.controller,
    required this.label,
    required this.onPreviewChanged,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<LinkPreview?> onPreviewChanged;
  final bool enabled;

  @override
  ConsumerState<LinkPreviewField> createState() => _LinkPreviewFieldState();
}

class _LinkPreviewFieldState extends ConsumerState<LinkPreviewField> {
  static const _debounce = Duration(milliseconds: 600);

  Timer? _timer;
  LinkPreview? _preview;
  bool _fetching = false;
  // Dismissal sticks for the CURRENT url text only.
  String? _dismissedForUrl;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _setPreview(LinkPreview? preview) {
    setState(() => _preview = preview);
    widget.onPreviewChanged(preview);
  }

  void _onChanged(String value) {
    _timer?.cancel();
    final trimmed = value.trim();
    if (_dismissedForUrl != null && _dismissedForUrl != trimmed) {
      _dismissedForUrl = null;
    }
    final parsed = Uri.tryParse(trimmed);
    final looksFetchable =
        parsed != null &&
        (parsed.isScheme('http') || parsed.isScheme('https')) &&
        parsed.host.contains('.');
    if (!looksFetchable || _dismissedForUrl == trimmed) {
      setState(() => _fetching = false);
      if (_preview != null) _setPreview(null);
      return;
    }
    _timer = Timer(_debounce, () async {
      setState(() => _fetching = true);
      final preview = await ref
          .read(linkPreviewRepositoryProvider)
          .fetch(trimmed);
      // The field may have moved on while fetching — apply only if current.
      if (!mounted || widget.controller.text.trim() != trimmed) return;
      setState(() => _fetching = false);
      _setPreview(preview); // null = silent fallback to free text
    });
  }

  void _remove() {
    _dismissedForUrl = widget.controller.text.trim();
    _setPreview(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: widget.controller,
          enabled: widget.enabled,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: widget.label,
            border: const OutlineInputBorder(),
            suffixIcon: _fetching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : null,
          ),
          onChanged: _onChanged,
        ),
        if (_preview != null) ...[
          const SizedBox(height: 8),
          LinkPreviewCard(preview: _preview!, onRemove: _remove),
        ],
      ],
    );
  }
}
