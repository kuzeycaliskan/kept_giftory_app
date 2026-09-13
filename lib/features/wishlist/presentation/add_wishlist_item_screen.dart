import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/link_preview/application/link_preview_providers.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/features/wishlist/application/wishlist_providers.dart';
import 'package:kept/shared/widgets/link_preview_card.dart';

/// Add-to-wishlist form (G-41). Photo attachment lands with the V2 media
/// pipeline (G-207).
class AddWishlistItemScreen extends ConsumerStatefulWidget {
  const AddWishlistItemScreen({super.key});

  @override
  ConsumerState<AddWishlistItemScreen> createState() =>
      _AddWishlistItemScreenState();
}

class _AddWishlistItemScreenState extends ConsumerState<AddWishlistItemScreen> {
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  final _noteController = TextEditingController();

  bool _titleMissing = false;

  static const _previewDebounce = Duration(milliseconds: 600);
  Timer? _previewTimer;
  LinkPreview? _preview;
  bool _fetchingPreview = false;
  // Set when the user dismissed the card for the CURRENT url text — don't
  // refetch until the url changes again.
  String? _dismissedForUrl;

  @override
  void dispose() {
    _previewTimer?.cancel();
    _titleController.dispose();
    _urlController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onUrlChanged(String value) {
    _previewTimer?.cancel();
    if (_dismissedForUrl != null && _dismissedForUrl != value.trim()) {
      _dismissedForUrl = null;
    }
    final trimmed = value.trim();
    final parsed = Uri.tryParse(trimmed);
    final looksFetchable =
        parsed != null &&
        (parsed.isScheme('http') || parsed.isScheme('https')) &&
        parsed.host.contains('.');
    if (!looksFetchable || _dismissedForUrl == trimmed) {
      setState(() {
        _preview = null;
        _fetchingPreview = false;
      });
      return;
    }
    _previewTimer = Timer(_previewDebounce, () async {
      setState(() => _fetchingPreview = true);
      final preview = await ref
          .read(linkPreviewRepositoryProvider)
          .fetch(trimmed);
      // The field may have changed while fetching — only apply if current.
      if (!mounted || _urlController.text.trim() != trimmed) return;
      setState(() {
        _fetchingPreview = false;
        _preview = preview; // null = silent fallback to free text
        // Convenience: an empty title inherits the product title.
        if (preview?.title != null && _titleController.text.trim().isEmpty) {
          _titleController.text = preview!.title!;
          _titleMissing = false;
        }
      });
    });
  }

  void _removePreview() {
    setState(() {
      _dismissedForUrl = _urlController.text.trim();
      _preview = null;
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _titleMissing = true);
      return;
    }
    final ok = await ref
        .read(wishlistControllerProvider.notifier)
        .add(
          title: title,
          note: _noteController.text,
          url: _urlController.text,
          linkPreviewId: _preview?.id,
        );
    if (ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.wishlistAddedSnack)));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(wishlistControllerProvider);
    final busy = state.isLoading;

    ref.listen(wishlistControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wishlistAddTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: l10n.wishlistItemTitleLabel,
                errorText: _titleMissing ? l10n.wishlistTitleRequired : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_titleMissing) setState(() => _titleMissing = false);
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: InputDecoration(
                labelText: l10n.wishlistItemUrlLabel,
                border: const OutlineInputBorder(),
                suffixIcon: _fetchingPreview
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
              onChanged: _onUrlChanged,
            ),
            if (_preview != null) ...[
              const SizedBox(height: 8),
              LinkPreviewCard(preview: _preview!, onRemove: _removePreview),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.wishlistItemNoteLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: busy ? null : _save,
              child: busy
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.commonSave),
            ),
          ],
        ),
      ),
    );
  }
}
