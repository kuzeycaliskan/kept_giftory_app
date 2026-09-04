import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Home tab. Real V1 dashboard (upcoming birthdays = real data, activity
/// panel = scaffold+mock) lands with G-82; the Activity bell lives here per
/// the nav decision (G-86).
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
      body: const Center(
        child: Text('Kept — skeleton ready'),
      ),
    );
  }
}
