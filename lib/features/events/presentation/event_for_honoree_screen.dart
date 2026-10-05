import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/events/application/events_providers.dart';
import 'package:kept/features/events/domain/event_kind.dart';

/// Route to open/join the event for a friend's occasion: their next
/// birthday by default, or an announced day (G-410b) with its kind, date
/// and (for "other") title in the query.
String eventForHonoreeRoute(
  String honoreeId, {
  EventKind kind = EventKind.birthday,
  DateTime? date,
  String? title,
}) {
  final query = <String, String>{
    if (!kind.isBirthday) 'kind': kind.wire,
    if (date != null)
      'date':
          '${date.year.toString().padLeft(4, '0')}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}',
    'title': ?title,
  };
  return Uri(
    path: '/events/for/$honoreeId',
    queryParameters: query.isEmpty ? null : query,
  ).toString();
}

/// Landing for the 14-day push and the Home row: opens (or joins) the event
/// for [honoreeId]'s occasion and replaces itself with the event. Shows a
/// spinner meanwhile; on failure it explains and goes back.
class EventForHonoreeScreen extends ConsumerStatefulWidget {
  const EventForHonoreeScreen({
    required this.honoreeId,
    this.kind = EventKind.birthday,
    this.date,
    this.title,
    super.key,
  });

  final String honoreeId;
  final EventKind kind;
  final DateTime? date;
  final String? title;

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
        .createOrJoin(
          widget.honoreeId,
          kind: widget.kind,
          date: widget.date,
          title: widget.title,
        );
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
