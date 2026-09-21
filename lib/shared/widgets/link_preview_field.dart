import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/link_preview/application/link_preview_providers.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/shared/widgets/link_preview_card.dart';

/// URL input with debounced product-preview fetching (G-211): pasting a
/// link shows a dismissible [LinkPreviewCard] under the field. A failed
/// fetch collapses to free text with a one-line hint — the surrounding form
/// never blocks. Share-sheet text ("Check this out! https://…") is reduced
/// to its link, since shops wrap the URL in words the user never wants kept.
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

  static final _urlPattern = RegExp(r'https?://[^\s<>"]+');

  /// The first http(s) link in [text], stripped of the closing punctuation
  /// share sheets tend to glue on; null when there is none.
  static String? extractUrl(String text) {
    final match = _urlPattern.firstMatch(text);
    if (match == null) return null;
    var url = match.group(0)!;
    while (url.isNotEmpty && ')].,;!?\'"'.contains(url[url.length - 1])) {
      url = url.substring(0, url.length - 1);
    }
    return url;
  }

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
  // The url whose fetch came back empty — the hint shows while it stays.
  String? _failedForUrl;

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
    var trimmed = value.trim();
    final embedded = LinkPreviewField.extractUrl(trimmed);
    if (embedded != null && embedded != trimmed) {
      // Pasted share text: keep only the link (what gets saved as the url).
      trimmed = embedded;
      widget.controller.value = TextEditingValue(
        text: embedded,
        selection: TextSelection.collapsed(offset: embedded.length),
      );
    }
    if (_dismissedForUrl != null && _dismissedForUrl != trimmed) {
      _dismissedForUrl = null;
    }
    if (_failedForUrl != null && _failedForUrl != trimmed) {
      _failedForUrl = null;
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
      setState(() {
        _fetching = false;
        _failedForUrl = preview == null ? trimmed : null;
      });
      _setPreview(preview); // null = free text, with the hint below
    });
  }

  void _remove() {
    _dismissedForUrl = widget.controller.text.trim();
    _setPreview(null);
  }

  @override
  Widget build(BuildContext context) {
    final failed =
        _failedForUrl != null && _failedForUrl == widget.controller.text.trim();
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
            helperText: failed ? context.l10n.linkPreviewUnavailable : null,
            helperMaxLines: 2,
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
