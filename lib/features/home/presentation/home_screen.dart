import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/features/home/application/home_providers.dart';
import 'package:kept/features/home/domain/activity_item.dart';
import 'package:kept/features/home/domain/upcoming_birthday.dart';

/// Home dashboard (G-82).
///
/// Upper "Upcoming" section shows real data (friends' birthdays). Lower
/// "Activity" panel is a scaffold fed by mock content until V2 (G-210) — it
/// carries a "sample" badge so testers don't mistake it for real events.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcoming = ref.watch(upcomingBirthdaysProvider);
    final activity = ref.watch(recentActivityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kept'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Activity',
            onPressed: () => context.push('/activity'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref
            ..invalidate(upcomingBirthdaysProvider)
            ..invalidate(recentActivityProvider);
          await ref.read(upcomingBirthdaysProvider.future);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const _SectionHeader(title: 'Upcoming'),
            const SizedBox(height: 8),
            _UpcomingSection(state: upcoming),
            const SizedBox(height: 24),
            const _SectionHeader(title: 'Activity', badge: 'sample'),
            const SizedBox(height: 8),
            _ActivitySection(state: activity),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.badge});

  final String title;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Chip(
            label: Text(badge!),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ],
    );
  }
}

class _UpcomingSection extends StatelessWidget {
  const _UpcomingSection({required this.state});

  final AsyncValue<List<UpcomingBirthday>> state;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => const _InlineError(
        message: 'Could not load upcoming birthdays',
      ),
      data: (birthdays) {
        if (birthdays.isEmpty) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(Icons.cake_outlined, size: 40),
                  const SizedBox(height: 8),
                  const Text('No upcoming birthdays yet'),
                  const SizedBox(height: 4),
                  Text(
                    'Add friends so you never miss a gift day.',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonal(
                    onPressed: () => context.go('/me'),
                    child: const Text('Find friends'),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            for (final b in birthdays) _BirthdayCard(birthday: b),
          ],
        );
      },
    );
  }
}

class _BirthdayCard extends StatelessWidget {
  const _BirthdayCard({required this.birthday});

  final UpcomingBirthday birthday;

  String get _countdown => switch (birthday.daysUntil) {
        0 => 'Today! 🎂',
        1 => 'Tomorrow',
        final d => 'In $d days',
      };

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          child: Text(birthday.label.substring(0, 1).toUpperCase()),
        ),
        title: Text(birthday.label),
        subtitle: Text('@${birthday.username} · $_countdown'),
        trailing: FilledButton.tonal(
          onPressed: () => context.push('/gifts/log'),
          child: const Text('Gift'),
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  const _ActivitySection({required this.state});

  final AsyncValue<List<ActivityItem>> state;

  IconData _icon(ActivityKind kind) => switch (kind) {
        ActivityKind.friendAccepted => Icons.group_add_outlined,
        ActivityKind.giftLogged => Icons.card_giftcard_outlined,
        ActivityKind.birthdayReminder => Icons.cake_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) =>
          const _InlineError(message: 'Could not load activity'),
      data: (items) {
        if (items.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: Text('Nothing happening yet')),
            ),
          );
        }
        return Card(
          child: Column(
            children: [
              for (final item in items)
                ListTile(
                  leading: Icon(_icon(item.kind)),
                  title: Text(item.text),
                  dense: true,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }
}
