import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/prefs/prefs_providers.dart';
import 'package:kept/features/events/application/events_providers.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/gifts/application/gift_photo_controller.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/reveal_math.dart';
import 'package:kept/features/gifts/presentation/widgets/gift_photo_strip.dart';
import 'package:kept/features/link_preview/domain/link_preview.dart';
import 'package:kept/shared/widgets/kept_date_picker.dart';
import 'package:kept/shared/widgets/link_preview_field.dart';

/// Log-a-gift form (G-51): recipient (an accepted friend), item, date,
/// optional note, surprise flag + reveal date (default: recipient's next
/// birthday + 1 day; computed server-agnostically from local data).
class LogGiftScreen extends ConsumerStatefulWidget {
  const LogGiftScreen({
    this.initialRecipientId,
    this.eventId,
    this.claimId,
    this.initialItem,
    this.initialUrl,
    super.key,
  });

  /// Pre-selected friend (e.g. a gift event's honoree).
  final String? initialRecipientId;

  /// Logging from a gift event: the gift is linked to it and opens with it.
  final String? eventId;

  /// A reservation turning into this gift (G-309): recipient fixed, item
  /// and link pre-filled, the record linked back to the claim.
  final String? claimId;
  final String? initialItem;
  final String? initialUrl;

  @override
  ConsumerState<LogGiftScreen> createState() => _LogGiftScreenState();
}

class _LogGiftScreenState extends ConsumerState<LogGiftScreen> {
  late final _itemController = TextEditingController(text: widget.initialItem);
  late final _linkController = TextEditingController(text: widget.initialUrl);

  /// Event gifts never open before the event: default and floor.
  DateTime? _eventRevealAt;
  final _noteController = TextEditingController();
  LinkPreview? _preview;

  late String? _recipientId = widget.initialRecipientId;
  DateTime? _recipientBirthday;
  DateTime _giftDate = DateTime.now();
  // Surprise is the default posture (product decision): logging a gift
  // shouldn't spoil it. Turning it off requires an explicit confirmation.
  bool _isSurprise = true;
  DateTime? _revealAt;

  bool _itemMissing = false;
  bool _recipientMissing = false;
  bool _revealMissing = false;

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
      // Convenience: an empty item field inherits the product title.
      if (preview?.title != null && _itemController.text.trim().isEmpty) {
        _itemController.text = preview!.titleForField!;
        _itemMissing = false;
      }
    });
  }

  /// Server timestamps arrive in UTC; the day they mean is the local one
  /// (a reveal at 00:00 Istanbul is still "the 16th", not the 15th).
  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date.toLocal());
  }

  Future<void> _pickGiftDate() async {
    final now = DateTime.now();
    final picked = await showKeptDatePicker(
      context,
      initialDate: _giftDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );
    if (picked != null) setState(() => _giftDate = picked);
  }

  Future<void> _pickRevealDate() async {
    final now = DateTime.now();
    final picked = await showKeptDatePicker(
      context,
      // Suggest the G-51 default (recipient's next birthday + 1 day), but
      // the user must confirm a date — nothing is submitted silently.
      initialDate:
          _revealAt ??
          _eventRevealAt ??
          defaultRevealAt(_recipientBirthday, now),
      firstDate: _eventRevealAt ?? now,
      lastDate: DateTime(now.year + 2),
    );
    if (picked != null) {
      setState(() {
        _revealAt = picked;
        _revealMissing = false;
      });
    }
  }

  /// Turning surprise OFF needs an explicit confirmation (with an optional
  /// persisted "don't show again"). Turning it ON is always silent.
  Future<void> _onSurpriseChanged(bool value) async {
    if (value) {
      setState(() => _isSurprise = true);
      return;
    }
    final prefs = await ref.read(sharedPreferencesProvider.future);
    if (prefs.getBool(PrefKeys.hideSurpriseOffWarning) ?? false) {
      setState(() => _isSurprise = false);
      return;
    }
    if (!mounted) return;
    final l10n = context.l10n;
    var dontShowAgain = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.surpriseOffTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.surpriseOffBody),
              CheckboxListTile(
                value: dontShowAgain,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(l10n.surpriseOffDontShowAgain),
                onChanged: (checked) =>
                    setDialogState(() => dontShowAgain = checked ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.surpriseOffConfirm),
            ),
          ],
        ),
      ),
    );
    if (confirmed ?? false) {
      if (dontShowAgain) {
        await prefs.setBool(PrefKeys.hideSurpriseOffWarning, true);
      }
      if (mounted) setState(() => _isSurprise = false);
    }
  }

  /// Photos taken before the gift exists; attached right after the insert.
  final List<Uint8List> _captures = [];

  Future<void> _capturePhoto() async {
    final bytes = await ref
        .read(giftPhotoControllerProvider.notifier)
        .capture();
    if (bytes == null || !mounted) return;
    setState(() => _captures.add(bytes));
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final item = _itemController.text.trim();
    setState(() {
      _itemMissing = item.isEmpty;
      _recipientMissing = _recipientId == null;
      // Reveal date is a conscious choice, never silently defaulted.
      _revealMissing =
          _isSurprise && _revealAt == null && _eventRevealAt == null;
    });
    if (_itemMissing || _recipientMissing || _revealMissing) return;

    final gift = await ref
        .read(giftsControllerProvider.notifier)
        .log(
          recipientId: _recipientId!,
          item: item,
          giftDate: _giftDate,
          isSurprise: _isSurprise,
          note: _noteController.text,
          revealAt: _isSurprise ? (_revealAt ?? _eventRevealAt) : null,
          linkPreviewId: _preview?.id,
          eventId: widget.eventId,
          claimId: widget.claimId,
        );
    if (gift == null || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final attached = await ref
        .read(giftPhotoControllerProvider.notifier)
        .attach(giftId: gift.id, captures: _captures);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          attached < _captures.length
              ? l10n.giftPhotoAttachPartial
              : l10n.logGiftSavedSnack,
        ),
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(giftsControllerProvider);
    final busy = state.isLoading;
    final friendsAsync = ref.watch(friendEntriesProvider);

    ref.listen(giftsControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });
    final eventId = widget.eventId;
    if (eventId != null) {
      // Derived on every build (the event page usually loaded it already,
      // so a change listener would never fire): the event's reveal is the
      // gift's reveal.
      _eventRevealAt = ref
          .watch(eventDetailProvider(eventId))
          .valueOrNull
          ?.revealAt;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.logGiftTitle)),
      body: friendsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.friendsError)),
        data: (entries) {
          final friends = entries
              .where((e) => e.status == FriendshipStatus.accepted)
              .toList();
          if (friends.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(l10n.logGiftNoFriends, textAlign: TextAlign.center),
              ),
            );
          }
          return _form(l10n, friends, busy);
        },
      ),
    );
  }

  Widget _form(AppLocalizations l10n, List<FriendEntry> friends, bool busy) {
    // From an event the recipient is the honoree, from a reservation the
    // list's owner — fixed, not a choice.
    final fromEvent = widget.eventId != null;
    final recipientLocked = fromEvent || widget.claimId != null;
    _recipientBirthday ??= friends
        .where((f) => f.profileId == _recipientId)
        .firstOrNull
        ?.birthday;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _recipientId,
            decoration: InputDecoration(
              labelText: l10n.logGiftRecipientLabel,
              errorText: _recipientMissing
                  ? l10n.logGiftRecipientRequired
                  : null,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final f in friends)
                DropdownMenuItem(value: f.profileId, child: Text(f.label)),
            ],
            onChanged: recipientLocked
                ? null
                : (value) => setState(() {
                    _recipientId = value;
                    _recipientBirthday = friends
                        .where((f) => f.profileId == value)
                        .firstOrNull
                        ?.birthday;
                    _recipientMissing = false;
                  }),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _itemController,
            maxLength: 200,
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
            onPressed: busy ? null : _pickGiftDate,
            icon: const Icon(Icons.event_outlined),
            label: Text('${l10n.logGiftDateLabel}: ${_formatDate(_giftDate)}'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: l10n.wishlistItemNoteLabel,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          if (fromEvent)
            // Event gifts are surprises by rule (server-enforced too).
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline),
              title: Text(l10n.logGiftSurprise),
              subtitle: Text(l10n.logGiftEventSurpriseNote),
            )
          else
            SwitchListTile(
              value: _isSurprise,
              title: Text(l10n.logGiftSurprise),
              subtitle: Text(l10n.logGiftSurpriseHint),
              onChanged: busy ? null : _onSurpriseChanged,
            ),
          if (fromEvent && _eventRevealAt != null)
            // Opens with the event — no date to pick.
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.visibility_outlined),
              title: Text(
                '${l10n.logGiftRevealDateLabel}: '
                '${_formatDate(_eventRevealAt!)}',
              ),
              subtitle: Text(l10n.logGiftEventRevealRule),
            )
          else if (_isSurprise) ...[
            OutlinedButton.icon(
              onPressed: busy ? null : _pickRevealDate,
              // Missing-and-required mirrors the text-field error look:
              // red frame + red content, not just the helper line.
              style: _revealMissing
                  ? OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    )
                  : null,
              icon: const Icon(Icons.visibility_outlined),
              label: Text(
                _revealAt == null
                    ? l10n.logGiftRevealDateLabel
                    : '${l10n.logGiftRevealDateLabel}: '
                          '${_formatDate(_revealAt!)}',
              ),
            ),
            if (_revealMissing)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 12),
                child: Text(
                  l10n.logGiftRevealDateRequired,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          ],
          const SizedBox(height: 24),
          PendingPhotoPicker(
            captures: _captures,
            enabled: !busy,
            captureLabel: l10n.giftPhotoAdd,
            capHint: l10n.giftPhotoCapHint,
            onCapture: _capturePhoto,
            onRemove: (i) => setState(() => _captures.removeAt(i)),
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
    );
  }
}
