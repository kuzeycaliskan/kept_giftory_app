import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  const ClaimBar({required this.item, required this.claim, super.key});

  final WishlistItem item;
  final WishlistClaim? claim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myId = ref.watch(myProfileProvider).valueOrNull?.id;
    final busy = ref.watch(claimsControllerProvider).isLoading;
    final claim = this.claim;
    final Widget child;
    if (claim == null) {
      child = _FreeActions(item: item, busy: busy);
    } else if (!claim.isShared) {
      child = _SoloState(item: item, claim: claim, myId: myId, busy: busy);
    } else {
      child = _SharedState(item: item, claim: claim, myId: myId, busy: busy);
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
  const _FreeActions({required this.item, required this.busy});

  final WishlistItem item;
  final bool busy;

  Future<void> _solo(BuildContext context, WidgetRef ref) async {
    final failure = await ref
        .read(claimsControllerProvider.notifier)
        .claim(item.ownerId, item.id, kind: ClaimKind.solo);
    if (context.mounted) _report(context, failure);
  }

  Future<void> _shared(BuildContext context, WidgetRef ref) async {
    final input = await showAmountSheet(
      context,
      title: context.l10n.claimSharedTitle,
      body: context.l10n.claimSharedBody,
      askTarget: true,
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
  });

  final WishlistItem item;
  final WishlistClaim claim;
  final String? myId;
  final bool busy;

  Future<void> _more(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final controller = ref.read(claimsControllerProvider.notifier);
    await showKeptActionSheet(
      context,
      actions: [
        KeptSheetAction(
          icon: Icons.group_outlined,
          label: l10n.claimMakeShared,
          onTap: () async {
            final input = await showAmountSheet(
              context,
              title: l10n.claimSharedTitle,
              body: l10n.claimSharedBody,
              askTarget: true,
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
          onTap: () async {
            final failure = await controller.release(item.ownerId, claim.id);
            if (context.mounted) _report(context, failure);
          },
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
        ? l10n.claimMine
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
  });

  final WishlistItem item;
  final WishlistClaim claim;
  final String? myId;
  final bool busy;

  Future<void> _pledge(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final input = await showAmountSheet(
      context,
      title: l10n.claimPledgeTitle,
      initialAmount: claim.pledgeOf(myId)?.amount,
    );
    if (input?.amount == null || !context.mounted) return;
    final failure = await ref
        .read(claimsControllerProvider.notifier)
        .pledge(item.ownerId, claim.id, input!.amount!);
    if (context.mounted) _report(context, failure);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final scheme = Theme.of(context).colorScheme;
    final total = formatTry(locale, claim.pledgedTotal);
    final target = claim.targetAmount;
    final amountText = target == null
        ? total
        : l10n.claimSharedTarget(total, formatTry(locale, target));
    final mine = claim.pledgeOf(myId);
    return Row(
      children: [
        Icon(Icons.group, size: 18, color: scheme.primary),
        const SizedBox(width: KeptSpacing.sm),
        Expanded(
          child: InkWell(
            borderRadius: BorderRadius.circular(KeptRadius.control),
            onTap: () => showParticipantsSheet(context, item: item),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: KeptSpacing.xs),
              child: Text(
                l10n.claimSharedSummary(claim.pledges.length, amountText),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: scheme.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: KeptSpacing.sm),
        if (mine == null)
          FilledButton.tonal(
            style: _compact,
            onPressed: busy ? null : () => _pledge(context, ref),
            child: Text(l10n.claimJoin),
          )
        else
          TextButton(
            style: _compact,
            onPressed: busy ? null : () => _pledge(context, ref),
            child: Text(
              l10n.claimMyPledge(formatTry(locale, mine.amount)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
    ),
  );
}

class _AmountSheet extends StatefulWidget {
  const _AmountSheet({
    required this.title,
    required this.askTarget,
    this.body,
    this.initialAmount,
  });

  final String title;
  final String? body;
  final bool askTarget;
  final double? initialAmount;

  @override
  State<_AmountSheet> createState() => _AmountSheetState();
}

class _AmountSheetState extends State<_AmountSheet> {
  late final _amount = TextEditingController(
    text: widget.initialAmount == null
        ? ''
        : formatTry('en', widget.initialAmount!).replaceAll('₺', ''),
  );
  final _target = TextEditingController();
  String? _amountError;

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
          const SizedBox(height: KeptSpacing.md),
          if (widget.askTarget) ...[
            TextField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.claimTargetHint),
            ),
            const SizedBox(height: KeptSpacing.sm),
          ],
          TextField(
            controller: _amount,
            autofocus: !widget.askTarget,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: widget.askTarget
                  ? l10n.claimPledgeTitle
                  : l10n.claimPledgeHint,
              errorText: _amountError,
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: KeptSpacing.lg),
          FilledButton(onPressed: _save, child: Text(l10n.commonSave)),
        ],
      ),
    );
  }
}

/// Who pledged what. Participants can withdraw; the organiser can remove
/// anyone or cancel the pool. Reads the live claim so rows update in place.
Future<void> showParticipantsSheet(
  BuildContext context, {
  required WishlistItem item,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => _ParticipantsSheet(item: item),
  );
}

class _ParticipantsSheet extends ConsumerWidget {
  const _ParticipantsSheet({required this.item});

  final WishlistItem item;

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
                        final failure = await controller.release(
                          item.ownerId,
                          claim.id,
                        );
                        if (!context.mounted) return;
                        _report(context, failure);
                        if (failure == null && navigator.canPop()) {
                          navigator.pop();
                        }
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
