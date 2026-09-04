import 'package:flutter/material.dart';

/// Placeholder Home. Real V1 Home dashboard (upcoming birthdays + scaffolded
/// activity panel) is G-82.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kept')),
      body: const Center(
        child: Text('Kept — skeleton ready'),
      ),
    );
  }
}
