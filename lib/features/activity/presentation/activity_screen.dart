import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';

/// Activity screen placeholder (G-86): friend requests + notifications list.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.activityTitle)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notifications_none, size: 56),
            const SizedBox(height: 12),
            Text(l10n.activityEmpty),
          ],
        ),
      ),
    );
  }
}
