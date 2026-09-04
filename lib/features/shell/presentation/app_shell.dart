import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kept/core/l10n/l10n.dart';
import 'package:kept/features/shell/presentation/quick_add_sheet.dart';

/// V1 navigation shell (G-81): bottom tabs Home / Gifts / ➕ Add / Me.
/// Add is an action (opens [QuickAddSheet]), not a tab — per the locked
/// navigation decision it becomes the camera in V2.
class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  static const int _addDestinationIndex = 2;

  /// Tab branch index (0,1,2) → destination index (0,1,3): the ➕ slot shifts
  /// everything after it by one.
  int get _selectedDestination {
    final branch = navigationShell.currentIndex;
    return branch < _addDestinationIndex ? branch : branch + 1;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    if (index == _addDestinationIndex) {
      QuickAddSheet.show(context);
      return;
    }
    final branch = index < _addDestinationIndex ? index : index - 1;
    navigationShell.goBranch(
      branch,
      initialLocation: branch == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedDestination,
        onDestinationSelected: (index) =>
            _onDestinationSelected(context, index),
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
            icon: const Icon(Icons.add_circle_outline),
            selectedIcon: const Icon(Icons.add_circle),
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
