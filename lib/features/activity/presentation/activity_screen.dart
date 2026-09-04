import 'package:flutter/material.dart';

/// Activity screen placeholder (G-86): friend requests + notifications list.
class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activity')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 56),
            SizedBox(height: 12),
            Text('Nothing here yet'),
          ],
        ),
      ),
    );
  }
}
