import 'package:flutter/material.dart';

/// Log-a-gift placeholder (G-51): the full form (recipient, item, surprise
/// flag, reveal_at) ships with the gifts feature.
class LogGiftScreen extends StatelessWidget {
  const LogGiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Log a gift')),
      body: const Center(child: Text('Gift logging arrives with G-51')),
    );
  }
}
