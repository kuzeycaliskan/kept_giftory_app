import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/events/application/events_providers.dart';

/// Landing for the 14-day push and the Home row: opens (or joins) the event
/// for [honoreeId]'s next birthday and replaces itself with the event.
/// Shows a spinner meanwhile; on failure it explains and goes back.
class EventForHonoreeScreen extends ConsumerStatefulWidget {
  const EventForHonoreeScreen({required this.honoreeId, super.key});

  final String honoreeId;

  @override
  ConsumerState<EventForHonoreeScreen> createState() =>
      _EventForHonoreeScreenState();
}

class _EventForHonoreeScreenState extends ConsumerState<EventForHonoreeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _resolve());
  }

  Future<void> _resolve() async {
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final id = await ref
        .read(eventsControllerProvider.notifier)
        .createOrJoin(widget.honoreeId);
    if (!mounted) return;
    if (id == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.eventsCreateFailed)));
      if (router.canPop()) router.pop();
      return;
    }
    unawaited(router.pushReplacement('/events/$id'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.eventsDetailTitle)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }
}
