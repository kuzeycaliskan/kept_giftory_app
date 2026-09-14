import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/gift_entry.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/shared/widgets/kept_date_picker.dart';
import 'package:kept/shared/widgets/link_preview_field.dart';

/// Localized label for a giver relation (shared with list rendering).
String giftRelationLabel(BuildContext context, GiftRelation relation) {
  final l10n = context.l10n;
  return switch (relation) {
    GiftRelation.mother => l10n.relationMother,
    GiftRelation.father => l10n.relationFather,
    GiftRelation.sibling => l10n.relationSibling,
    GiftRelation.partner => l10n.relationPartner,
    GiftRelation.relative => l10n.relationRelative,
    GiftRelation.friend => l10n.relationFriend,
    GiftRelation.coworker => l10n.relationCoworker,
    GiftRelation.other => l10n.relationOther,
  };
}

/// Log a gift received from a non-member (G-212): relation dropdown (never
/// free text), item, date, optional note/link. No surprise mechanics — it's
/// the recipient's own record.
class LogExternalGiftScreen extends ConsumerStatefulWidget {
  const LogExternalGiftScreen({super.key});

  @override
  ConsumerState<LogExternalGiftScreen> createState() =>
      _LogExternalGiftScreenState();
}

class _LogExternalGiftScreenState extends ConsumerState<LogExternalGiftScreen> {
  final _itemController = TextEditingController();
  final _linkController = TextEditingController();
  final _noteController = TextEditingController();

  GiftRelation? _relation;
  DateTime _giftDate = DateTime.now();
  LinkPreview? _preview;

  bool _itemMissing = false;
  bool _relationMissing = false;

  @override
  void dispose() {
    _itemController.dispose();
    _linkController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onPreviewChanged(LinkPreview? preview) {
    setState(() {
      _preview = preview;
      if (preview?.title != null && _itemController.text.trim().isEmpty) {
        _itemController.text = preview!.title!;
        _itemMissing = false;
      }
    });
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showKeptDatePicker(
      context,
      initialDate: _giftDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) setState(() => _giftDate = picked);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final item = _itemController.text.trim();
    setState(() {
      _itemMissing = item.isEmpty;
      _relationMissing = _relation == null;
    });
    if (_itemMissing || _relationMissing) return;

    final ok = await ref
        .read(giftsControllerProvider.notifier)
        .logExternal(
          relation: _relation!,
          item: item,
          giftDate: _giftDate,
          note: _noteController.text,
          linkPreviewId: _preview?.id,
        );
    if (ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.logGiftSavedSnack)));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final busy = ref.watch(giftsControllerProvider).isLoading;

    ref.listen(giftsControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.logExternalTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            DropdownButtonFormField<GiftRelation>(
              initialValue: _relation,
              decoration: InputDecoration(
                labelText: l10n.logExternalFromLabel,
                errorText: _relationMissing
                    ? l10n.logExternalFromRequired
                    : null,
                border: const OutlineInputBorder(),
              ),
              items: [
                for (final relation in GiftRelation.values)
                  DropdownMenuItem(
                    value: relation,
                    child: Text(giftRelationLabel(context, relation)),
                  ),
              ],
              onChanged: busy
                  ? null
                  : (value) => setState(() {
                      _relation = value;
                      _relationMissing = false;
                    }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _itemController,
              maxLength: 200,
              enabled: !busy,
              decoration: InputDecoration(
                labelText: l10n.logGiftItemLabel,
                errorText: _itemMissing ? l10n.logGiftItemRequired : null,
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) {
                if (_itemMissing) setState(() => _itemMissing = false);
              },
            ),
            const SizedBox(height: 16),
            LinkPreviewField(
              controller: _linkController,
              label: l10n.logGiftLinkLabel,
              enabled: !busy,
              onPreviewChanged: _onPreviewChanged,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: busy ? null : _pickDate,
              icon: const Icon(Icons.event_outlined),
              label: Text(
                '${l10n.logGiftDateLabel}: '
                '${DateFormat.yMMMd(locale).format(_giftDate)}',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _noteController,
              maxLines: 3,
              enabled: !busy,
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
