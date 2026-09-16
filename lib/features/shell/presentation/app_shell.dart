import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/feed/presentation/moment_capture.dart';

/// Navigation shell (G-81): bottom tabs Home / Gifts / ➕ / Me.
/// The center slot is an action, not a tab: per the locked navigation
/// decision it opens the camera (G-201) — a moment is taken, not picked.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const int _addDestinationIndex = 2;

  /// Tab branch index (0,1,2) → destination index (0,1,3): the ➕ slot shifts
  /// everything after it by one.
  int get _selectedDestination {
    final branch = navigationShell.currentIndex;
    return branch < _addDestinationIndex ? branch : branch + 1;
  }

  void _onDestinationSelected(BuildContext context, WidgetRef ref, int index) {
    if (index == _addDestinationIndex) {
      captureMoment(context, ref);
      return;
    }
    final branch = index < _addDestinationIndex ? index : index - 1;
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedDestination,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, ref, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: l10n.tabHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.card_giftcard_outlined),
            selectedIcon: const Icon(Icons.card_giftcard),
            label: l10n.tabGifts,
          ),
          NavigationDestination(
            icon: const Icon(Icons.photo_camera_outlined),
            selectedIcon: const Icon(Icons.photo_camera),
            label: l10n.tabAdd,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.tabMe,
          ),
        ],
      ),
    );
  }
}
