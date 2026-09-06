import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/profile/application/profile_providers.dart';
import 'package:kept/features/profile/domain/profile.dart';

/// Username / display-name search (G-32). Results respect RLS: only profiles
/// the caller may see (public, friends, pending parties) come back. Tapping a
/// result opens the profile screen, where the friendship action lives (G-84).
class FriendSearchScreen extends ConsumerStatefulWidget {
  const FriendSearchScreen({super.key});

  @override
  ConsumerState<FriendSearchScreen> createState() => _FriendSearchScreenState();
}

class _FriendSearchScreenState extends ConsumerState<FriendSearchScreen> {
  static const _debounce = Duration(milliseconds: 350);
  static const _minQueryLength = 2;

  final _controller = TextEditingController();
  Timer? _timer;
  String _query = '';

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _timer?.cancel();
    _timer = Timer(_debounce, () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l10n.searchHint,
            border: InputBorder.none,
          ),
          onChanged: _onChanged,
        ),
        actions: [
          IconButton(
            tooltip: l10n.searchClear,
            icon: const Icon(Icons.close),
            onPressed: () {
              _timer?.cancel();
              _controller.clear();
              setState(() => _query = '');
            },
          ),
        ],
      ),
      body: _query.length < _minQueryLength
          ? _CenteredHint(l10n.searchPrompt)
          : _SearchResults(query: _query),
    );
  }
}

class _SearchResults extends ConsumerWidget {
  const _SearchResults({required this.query});

  final String query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final results = ref.watch(profileSearchProvider(query));
    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _CenteredHint(l10n.searchError),
      data: (profiles) {
        if (profiles.isEmpty) return _CenteredHint(l10n.searchEmpty);
        return ListView.builder(
          itemCount: profiles.length,
          itemBuilder: (context, index) {
            final profile = profiles[index];
            return _ResultTile(profile: profile);
          },
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  const _ResultTile({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final name = profile.displayName ?? profile.username;
    return ListTile(
      leading: CircleAvatar(child: Text(name.characters.first.toUpperCase())),
      title: Text(name),
      subtitle: Text('@${profile.username}'),
      onTap: () => context.push(
        Uri(
          path: '/users/${profile.id}',
          queryParameters: {'name': name},
        ).toString(),
      ),
    );
  }
}

class _CenteredHint extends StatelessWidget {
  const _CenteredHint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
