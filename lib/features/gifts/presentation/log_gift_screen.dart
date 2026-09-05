import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/prefs/prefs_providers.dart';
import 'package:kept/features/friends/application/friends_providers.dart';
import 'package:kept/features/friends/domain/friend_entry.dart';
import 'package:kept/features/gifts/application/gifts_providers.dart';
import 'package:kept/features/gifts/domain/reveal_math.dart';
import 'package:kept/shared/widgets/kept_date_picker.dart';

/// Log-a-gift form (G-51): recipient (an accepted friend), item, date,
/// optional note, surprise flag + reveal date (default: recipient's next
/// birthday + 1 day; computed server-agnostically from local data).
class LogGiftScreen extends ConsumerStatefulWidget {
  const LogGiftScreen({super.key});

  @override
  ConsumerState<LogGiftScreen> createState() => _LogGiftScreenState();
}

class _LogGiftScreenState extends ConsumerState<LogGiftScreen> {
  final _itemController = TextEditingController();
  final _noteController = TextEditingController();

  String? _recipientId;
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
    _noteController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
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
      initialDate: _revealAt ?? defaultRevealAt(_recipientBirthday, now),
      firstDate: now,
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

  Future<void> _save() async {
    final l10n = context.l10n;
    final item = _itemController.text.trim();
    setState(() {
      _itemMissing = item.isEmpty;
      _recipientMissing = _recipientId == null;
      // Reveal date is a conscious choice, never silently defaulted.
      _revealMissing = _isSurprise && _revealAt == null;
    });
    if (_itemMissing || _recipientMissing || _revealMissing) return;

    final ok = await ref.read(giftsControllerProvider.notifier).log(
          recipientId: _recipientId!,
          item: item,
          giftDate: _giftDate,
          isSurprise: _isSurprise,
          note: _noteController.text,
          revealAt: _isSurprise ? _revealAt : null,
        );
    if (ok && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.logGiftSavedSnack)));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(giftsControllerProvider);
    final busy = state.isLoading;
    final friendsAsync = ref.watch(friendEntriesProvider);

    ref.listen(giftsControllerProvider, (_, next) {
      if (next.hasError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.errorGeneric)));
      }
    });

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
                child: Text(
                  l10n.logGiftNoFriends,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return _form(l10n, friends, busy);
        },
      ),
    );
  }

  Widget _form(AppLocalizations l10n, List<FriendEntry> friends, bool busy) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _recipientId,
            decoration: InputDecoration(
              labelText: l10n.logGiftRecipientLabel,
              errorText:
                  _recipientMissing ? l10n.logGiftRecipientRequired : null,
              border: const OutlineInputBorder(),
            ),
            items: [
              for (final f in friends)
                DropdownMenuItem(
                  value: f.profileId,
                  child: Text(f.label),
                ),
            ],
            onChanged: (value) => setState(() {
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
          SwitchListTile(
            value: _isSurprise,
            title: Text(l10n.logGiftSurprise),
            subtitle: Text(l10n.logGiftSurpriseHint),
            onChanged: busy ? null : _onSurpriseChanged,
          ),
          if (_isSurprise) ...[
            OutlinedButton.icon(
              onPressed: busy ? null : _pickRevealDate,
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
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
