import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/error/failure.dart';
import 'package:kept/core/format/money.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/core/theme/kept_tokens.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/wishlist/application/claims_providers.dart';
import 'package:kept/features/wishlist/domain/wishlist_claim.dart';
import 'package:kept/features/wishlist/domain/wishlist_item.dart';
import 'package:kept/shared/widgets/kept_action_sheet.dart';
import 'package:kept/shared/widgets/kept_avatar.dart';
import 'package:kept/shared/widgets/kept_list_group.dart';

/// The reservation strip under a friend's wishlist item (G-303/G-304):
/// free → "I'll get this" / "Chip in together"; taken → who; pool →
/// progress + join. The owner never renders this (their claims are
/// RLS-hidden, so the map is empty and the screen is theirs anyway).
class ClaimBar extends ConsumerWidget {
  const ClaimBar({
    required this.item,
    required this.claim,
    this.eventId,
    super.key,
  });

  final WishlistItem item;
  final WishlistClaim? claim;

  /// Set when the strip lives on an event page: the gift record then links
  /// to the event too (otherwise the server hooks it up on its own).
  final String? eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(myProfileProvider).valueOrNull?.id;
    final busy = ref.watch(claimsControllerProvider).isLoading;
    final claim = this.claim;
    final Widget child;
    if (claim == null) {
      child = _FreeActions(item: item, busy: busy, eventId: eventId);
    } else if (!claim.isShared) {
      child = _SoloState(
        item: item,
        claim: claim,
        myId: myId,
        busy: busy,
        eventId: eventId,
      );
    } else {
      child = _SharedState(
        item: item,
        claim: claim,
        myId: myId,
        busy: busy,
        eventId: eventId,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KeptSpacing.lg,
        0,
        KeptSpacing.lg,
        KeptSpacing.sm,
      ),
      child: child,
    );
  }
}

/// The product card's price, when the shop exposed one — the pool goal
/// starts there and stays editable.
double? _priceOf(WishlistItem item) {
  final price = item.preview?.price;
  return price == null ? null : parseAmount(price);
}

/// The gift form, pre-filled from the item and linked back to the claim.
String logGiftRouteFor(
  WishlistItem item,
  WishlistClaim claim,
  String? eventId,
) {
  final title = item.preview?.title ?? item.title;
  final url = item.preview?.url ?? item.url;
  final query = <String, String>{
    'recipient': item.ownerId,
    'claim': claim.id,
    'item': title,
    if (url != null) 'url': url,
    if (eventId != null) 'event': eventId,
  };
  return Uri(path: '/gifts/log', queryParameters: query).toString();
}

/// Shows the outcome of a claim action; a lost race gets its own words.
void _report(BuildContext context, Failure? failure) {
  if (failure == null || !context.mounted) return;
  final l10n = context.l10n;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        failure is ConflictFailure ? l10n.claimTaken : l10n.claimFailed,
      ),
    ),
  );
}

final _compact = ButtonStyle(
  visualDensity: VisualDensity.compact,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  padding: WidgetStateProperty.all(
    const EdgeInsets.symmetric(horizontal: KeptSpacing.md),
  ),
);

class _FreeActions extends ConsumerWidget {
  const _FreeActions({
    required this.item,
    required this.busy,
    required this.eventId,
  });

  final WishlistItem item;
  final bool busy;
  final String? eventId;

  /// "I'm getting this" is a commitment: confirm, reserve, then straight
  /// into the gift record so the wishlist and the gift never diverge.
  Future<void> _solo(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.claimSoloConfirmTitle),
        content: Text(l10n.claimSoloConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.claimSoloConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final claim = await ref
        .read(claimsControllerProvider.notifier)
        .claimForGift(item.ownerId, item.id);
    if (!context.mounted) return;
    if (claim == null) {
      final failure = ref.read(claimsControllerProvider).error;
      _report(context, failure is Failure ? failure : const UnknownFailure());
      return;
    }
    unawaited(context.push(logGiftRouteFor(item, claim, eventId)));
  }

  Future<void> _shared(BuildContext context, WidgetRef ref) async {
    final input = await showAmountSheet(
      context,
      title: context.l10n.claimSharedTitle,
      body: context.l10n.claimSharedBody,
      askTarget: true,
      initialTarget: _priceOf(item),
    );
    if (input == null || !context.mounted) return;
    final controller = ref.read(claimsControllerProvider.notifier);
    final failure = await controller.claim(
      item.ownerId,
      item.id,
      kind: ClaimKind.shared,
      targetAmount: input.target,
    );
    if (!context.mounted) return;
    if (failure != null) {
      _report(context, failure);
      return;
    }
    final pledge = input.amount;
    if (pledge == null) return;
    // The pool exists now; my own share is a pledge like anyone else's.
    final claims = await ref.read(wishlistClaimsProvider(item.ownerId).future);
    final claim = claims[item.id];
    if (claim == null) return;
    final pledged = await controller.pledge(item.ownerId, claim.id, pledge);
    if (context.mounted) _report(context, pledged);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Wrap(
      spacing: KeptSpacing.sm,
      runSpacing: KeptSpacing.xs,
      children: [
        OutlinedButton.icon(
          style: _compact,
          onPressed: busy ? null : () => _solo(context, ref),
          icon: const Icon(Icons.check, size: 18),
          label: Text(l10n.claimSolo),
        ),
        OutlinedButton.icon(
          style: _compact,
          onPressed: busy ? null : () => _shared(context, ref),
          icon: const Icon(Icons.group_outlined, size: 18),
          label: Text(l10n.claimShared),
        ),
      ],
    );
  }
}

class _SoloState extends ConsumerWidget {
  const _SoloState({
    required this.item,
    required this.claim,
    required this.myId,
    required this.busy,
    required this.eventId,
  });

  final WishlistItem item;
  final WishlistClaim claim;
  final String? myId;
  final bool busy;
  final String? eventId;

  Future<void> _more(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = ref.read(claimsControllerProvider.notifier);
    await showKeptActionSheet(
      context,
      actions: [
        if (claim.hasGift)
          KeptSheetAction(
            icon: Icons.redeem_outlined,
            label: l10n.claimOpenGift,
            onTap: () => context.push('/gifts/${claim.giftId}?side=recipient'),
          )
        else
          KeptSheetAction(
            icon: Icons.redeem_outlined,
            label: l10n.claimLogGift,
            onTap: () => context.push(logGiftRouteFor(item, claim, eventId)),
          ),
        if (!claim.hasGift)
          KeptSheetAction(
            icon: Icons.group_outlined,
            label: l10n.claimMakeShared,
            onTap: () async {
              final input = await showAmountSheet(
                context,
                title: l10n.claimSharedTitle,
                body: l10n.claimSharedBody,
                askTarget: true,
                initialTarget: _priceOf(item),
              );
              if (input == null || !context.mounted) return;
              final failure = await controller.makeShared(
                item.ownerId,
                claim.id,
                targetAmount: input.target,
              );
              if (!context.mounted) return;
              if (failure != null) {
                _report(context, failure);
                return;
              }
              if (input.amount != null) {
                final pledged = await controller.pledge(
                  item.ownerId,
                  claim.id,
                  input.amount!,
                );
                if (context.mounted) _report(context, pledged);
              }
            },
          ),
        KeptSheetAction(
          icon: Icons.undo,
          label: l10n.claimRelease,
          destructive: true,
          onTap: () => releaseClaim(context, ref, item, claim),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final mine = claim.isMine(myId);
    final label = mine
        ? (claim.hasGift ? l10n.claimMineLogged : l10n.claimMine)
        : claim.claimer == null
        ? l10n.claimByFriend
        : l10n.claimByOther(claim.claimerLabelOr(''));
    return Row(
      children: [
        Icon(
          mine ? Icons.check_circle : Icons.lock_outline,
          size: 18,
          color: mine ? scheme.primary : scheme.onSurfaceVariant,
        ),
        const SizedBox(width: KeptSpacing.sm),
        Expanded(
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: mine ? scheme.primary : scheme.onSurfaceVariant,
            ),
          ),
        ),
        if (mine)
          IconButton(
            tooltip: l10n.storyMoreActions,
            icon: const Icon(Icons.more_horiz),
            onPressed: busy ? null : () => _more(context, ref),
          ),
      ],
    );
  }
}

class _SharedState extends ConsumerWidget {
  const _SharedState({
    required this.item,
    required this.claim,
    required this.myId,
    required this.busy,
    required this.eventId,
  });

  final WishlistItem item;
  final WishlistClaim claim;
  final String? myId;
  final bool busy;
  final String? eventId;

  Future<void> _pledge(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final target = claim.targetAmount;
    final mine = claim.pledgeOf(myId)?.amount;
    final remaining = target == null ? null : _remaining(target);
    final input = await showAmountSheet(
      context,
      title: l10n.claimPledgeTitle,
      body: target == null
          ? null
          : l10n.claimJoinHint(
              formatTry(locale, remaining!),
              claim.pledges.length,
            ),
      // A newcomer is offered what is still missing (editable); someone
      // changing their share sees it as it is.
      initialAmount:
          mine ?? (remaining != null && remaining > 0 ? remaining : null),
      // The pool stays flexible (street price may differ) — going past the
      // price only earns a heads-up, never a block.
      overflowAt: remaining == null ? null : remaining + (mine ?? 0),
    );
    if (input?.amount == null || !context.mounted) return;
    final failure = await ref
        .read(claimsControllerProvider.notifier)
        .pledge(item.ownerId, claim.id, input!.amount!);
    if (!context.mounted) return;
    if (failure is ConflictFailure) {
      // The pool filled up while the sheet was open.
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.claimPoolFull)));
      return;
    }
    _report(context, failure);
  }

  /// Reached its price: closed to newcomers (server-enforced too).
  bool get _full =>
      claim.targetAmount != null && claim.pledgedTotal >= claim.targetAmount!;

  double _remaining(double target) =>
      (target - claim.pledgedTotal).clamp(0, target).toDouble();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final target = claim.targetAmount;
    final mine = claim.pledgeOf(myId);
    final organizer = claim.isMine(myId);

    // One next step, never several: what this viewer can do right now.
    final Widget action;
    if (claim.hasGift) {
      action = TextButton.icon(
        style: _compact,
        onPressed: () => context.push('/gifts/${claim.giftId}?side=recipient'),
        icon: const Icon(Icons.redeem_outlined, size: 18),
        label: Text(l10n.claimOpenGift),
      );
    } else if (organizer && _full) {
      // The pool reached its price: the organizer's next step is the
      // gift record (the server takes exactly one per pool).
      action = FilledButton.icon(
        style: _compact,
        onPressed: busy
            ? null
            : () => context.push(logGiftRouteFor(item, claim, eventId)),
        icon: const Icon(Icons.redeem_outlined, size: 18),
        label: Text(l10n.claimLogGift),
      );
    } else if (mine == null && _full) {
      action = Text(
        l10n.claimPoolFull,
        style: theme.textTheme.labelLarge?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      );
    } else if (mine == null) {
      action = FilledButton.tonal(
        style: _compact,
        onPressed: busy ? null : () => _pledge(context, ref),
        child: Text(l10n.claimJoin),
      );
    } else {
      action = TextButton(
        style: _compact,
        onPressed: busy ? null : () => _pledge(context, ref),
        child: Text(
          l10n.claimMyPledge(formatTry(locale, mine.amount)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    // Three quiet rows: what it is (tap for who's in), where the money
    // stands, and the one thing to do — instead of one crowded line.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(KeptRadius.control),
          onTap: () =>
              showParticipantsSheet(context, item: item, eventId: eventId),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: KeptSpacing.xs),
            child: Row(
              children: [
                Icon(Icons.group, size: 18, color: scheme.primary),
                const SizedBox(width: KeptSpacing.sm),
                Expanded(
                  child: Text(
                    claim.hasGift
                        ? l10n.claimSharedLogged
                        : l10n.claimSharedHeader(claim.pledges.length),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.primary,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        if (target != null)
          _PoolProgress(total: claim.pledgedTotal, target: target)
        else
          Text(
            l10n.claimSharedGathered(formatTry(locale, claim.pledgedTotal)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: KeptSpacing.xs),
          child: Align(alignment: Alignment.centerRight, child: action),
        ),
      ],
    );
  }
}

/// Where the money stands: a full-width bar and one line under it —
/// gathered / price, then what is missing, or by how much it went over
/// (pools are deliberately not capped).
class _PoolProgress extends StatelessWidget {
  const _PoolProgress({required this.total, required this.target});

  final double total;
  final double target;

  String _label(AppLocalizations l10n, String locale) {
    final amounts = l10n.claimSharedTarget(
      formatTry(locale, total),
      formatTry(locale, target),
    );
    final over = total - target;
    if (over > 0) {
      return '$amounts · ${l10n.claimOverTarget(formatTry(locale, over))}';
    }
    if (over == 0) return '$amounts · ${l10n.claimFunded}';
    return '$amounts · ${l10n.claimRemaining(formatTry(locale, -over))}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final overTarget = total > target;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(KeptRadius.pill),
          child: LinearProgressIndicator(
            value: (total / target).clamp(0, 1).toDouble(),
            minHeight: 6,
            color: overTarget ? theme.colorScheme.tertiary : null,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
        const SizedBox(height: KeptSpacing.xs),
        Text(
          _label(l10n, locale),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: overTarget
                ? theme.colorScheme.tertiary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// What the amount sheet returns: the pool goal (when asked) and my share.
/// Both optional — a pool may open without a goal or a first pledge.
@immutable
class AmountInput {
  const AmountInput({this.amount, this.target});

  final double? amount;
  final double? target;
}

/// Amount entry for pledges and pool goals. Returns null when dismissed.
Future<AmountInput?> showAmountSheet(
  BuildContext context, {
  required String title,
  String? body,
  bool askTarget = false,
  double? initialAmount,
  double? initialTarget,
  double? overflowAt,
}) {
  return showModalBottomSheet<AmountInput>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _AmountSheet(
      title: title,
      body: body,
      askTarget: askTarget,
      initialAmount: initialAmount,
      initialTarget: initialTarget,
      overflowAt: overflowAt,
    ),
  );
}

class _AmountSheet extends StatefulWidget {
  const _AmountSheet({
    required this.title,
    required this.askTarget,
    this.body,
    this.initialAmount,
    this.initialTarget,
    this.overflowAt,
  });

  final String title;
  final String? body;
  final bool askTarget;
  final double? initialAmount;

  /// Pre-filled pool goal (the product card's price); editable.
  final double? initialTarget;

  /// Amount above which the pool passes its price — shown as a hint while
  /// typing, never enforced.
  final double? overflowAt;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late final _amount = TextEditingController(
    text: widget.initialAmount == null
        ? ''
        : plainAmount(widget.initialAmount!),
  );
  late final _target = TextEditingController(
    text: widget.initialTarget == null
        ? ''
        : plainAmount(widget.initialTarget!),
  );
  String? _amountError;

  String? _overflowHint(AppLocalizations l10n, String locale) {
    final limit = widget.overflowAt;
    if (limit == null) return null;
    final amount = parseAmount(_amount.text);
    if (amount == null || amount <= limit) return null;
    return l10n.claimOverTargetHint(formatTry(locale, amount - limit));
  }

  @override
  void dispose() {
    _amount.dispose();
    _target.dispose();
    super.dispose();
  }

  void _save() {
    final l10n = context.l10n;
    final amountText = _amount.text.trim();
    final amount = amountText.isEmpty ? null : parseAmount(amountText);
    // A pledge sheet needs a number; the pool sheet allows "no share yet".
    final amountRequired = !widget.askTarget;
    if ((amountRequired && amount == null) ||
        (amountText.isNotEmpty && amount == null)) {
      setState(() => _amountError = l10n.claimPledgeInvalid);
      return;
    }
    final targetText = _target.text.trim();
    final target = targetText.isEmpty ? null : parseAmount(targetText);
    Navigator.of(context).pop(AmountInput(amount: amount, target: target));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        KeptSpacing.lg,
        0,
        KeptSpacing.lg,
        MediaQuery.viewInsetsOf(context).bottom + KeptSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(widget.title, style: theme.textTheme.titleMedium),
          if (widget.body != null) ...[
            const SizedBox(height: KeptSpacing.xs),
            Text(
              widget.body!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: KeptSpacing.lg),
          // Captions sit above the filled fields (the theme's borderless
          // fill leaves no room for a floating label), so both fields read
          // the same and keep one height.
          if (widget.askTarget) ...[
            _Caption(l10n.claimTargetHint),
            TextField(
              key: const Key('claim-target'),
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(prefixText: '₺ '),
            ),
            const SizedBox(height: KeptSpacing.md),
          ],
          _Caption(
            widget.askTarget ? l10n.claimMyShareOptional : l10n.claimPledgeHint,
          ),
          TextField(
            key: const Key('claim-amount'),
            controller: _amount,
            autofocus: !widget.askTarget,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              prefixText: '₺ ',
              errorText: _amountError,
              helperText: _overflowHint(l10n, locale),
              helperMaxLines: 2,
            ),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: KeptSpacing.lg),
          FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
        ],
      ),
    );
  }
}

class _Caption extends StatelessWidget {
  const _Caption(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        left: KeptSpacing.xs,
        bottom: KeptSpacing.xs,
      ),
      child: Text(
        text,
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Who pledged what. Participants can withdraw; the organiser can remove
/// anyone or cancel the pool. Reads the live claim so rows update in place.
Future<void> showParticipantsSheet(
  BuildContext context, {
  required WishlistItem item,
  String? eventId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _ParticipantsSheet(item: item, eventId: eventId),
  );
}

/// Releasing a reservation that already has a gift record deletes that
/// record (while unrevealed) — say so first; a gift already given cannot
/// be released at all, and the server says no.
Future<void> releaseClaim(
  BuildContext context,
  WidgetRef ref,
  WishlistItem item,
  WishlistClaim claim,
) async {
  final l10n = context.l10n;
  if (claim.hasGift) {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.claimReleaseGiftTitle),
        content: Text(l10n.claimReleaseGiftBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.claimRelease),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
  }
  final failure = await ref
      .read(claimsControllerProvider.notifier)
      .release(item.ownerId, claim.id);
  if (!context.mounted) return;
  if (failure is ConflictFailure) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.claimReleaseRefused)));
    return;
  }
  _report(context, failure);
}

class _ParticipantsSheet extends ConsumerWidget {
  const _ParticipantsSheet({required this.item, this.eventId});

  final WishlistItem item;
  final String? eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final theme = Theme.of(context);
    final myId = ref.watch(myProfileProvider).valueOrNull?.id;
    final busy = ref.watch(claimsControllerProvider).isLoading;
    final claim = ref
        .watch(wishlistClaimsProvider(item.ownerId))
        .valueOrNull?[item.id];
    final controller = ref.read(claimsControllerProvider.notifier);
    if (claim == null || !claim.isShared) {
      // Cancelled underneath us — nothing to manage.
      return const SizedBox(height: KeptSpacing.xxl);
    }
    final organizer = claim.isMine(myId);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KeptSpacing.lg,
          0,
          KeptSpacing.lg,
          KeptSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.claimParticipants, style: theme.textTheme.titleMedium),
            const SizedBox(height: KeptSpacing.sm),
            if (claim.pledges.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: KeptSpacing.md),
                child: Text(
                  l10n.claimNoPledges,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              )
            else
              Flexible(
                child: SingleChildScrollView(
                  child: KeptListGroup(
                    children: [
                      for (final p in claim.pledges)
                        ListTile(
                          leading: KeptAvatar(
                            label: p.labelOr(l10n.giftAnonymousGiver),
                            avatarValue: p.user?.avatarUrl,
                          ),
                          title: Text(
                            p.labelOr(l10n.giftAnonymousGiver),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: p.userId == claim.claimerId
                              ? Text(l10n.claimOrganizer)
                              : null,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                formatTry(locale, p.amount),
                                style: theme.textTheme.titleSmall,
                              ),
                              if (organizer || p.userId == myId)
                                IconButton(
                                  tooltip: p.userId == myId
                                      ? l10n.claimWithdraw
                                      : l10n.claimRemovePledge,
                                  icon: const Icon(Icons.close),
                                  onPressed: busy
                                      ? null
                                      : () async {
                                          final failure = await controller
                                              .withdrawPledge(
                                                item.ownerId,
                                                claim.id,
                                                p.userId,
                                              );
                                          if (context.mounted) {
                                            _report(context, failure);
                                          }
                                        },
                                ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            if (organizer && !claim.hasGift && claim.pledges.isNotEmpty) ...[
              const SizedBox(height: KeptSpacing.md),
              FilledButton.icon(
                onPressed: busy
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        unawaited(
                          context.push(logGiftRouteFor(item, claim, eventId)),
                        );
                      },
                icon: const Icon(Icons.redeem_outlined),
                label: Text(l10n.claimLogGift),
              ),
            ],
            if (organizer) ...[
              const SizedBox(height: KeptSpacing.md),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
                onPressed: busy
                    ? null
                    : () async {
                        final navigator = Navigator.of(context);
                        await releaseClaim(context, ref, item, claim);
                        if (!context.mounted) return;
                        final gone =
                            ref
                                .read(wishlistClaimsProvider(item.ownerId))
                                .valueOrNull?[item.id] ==
                            null;
                        if (gone && navigator.canPop()) navigator.pop();
                      },
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.claimCancelShared),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
