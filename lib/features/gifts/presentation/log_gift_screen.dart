import 'package:flutter/material.dart';
import 'package:kept/core/l10n/l10n.dart';

/// Log-a-gift placeholder (G-51): the full form (recipient, item, surprise
/// flag, reveal_at) ships with the gifts feature.
class LogGiftScreen extends StatelessWidget {
  const LogGiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.logGiftTitle)),
      body: Center(child: Text(l10n.logGiftComingSoon)),
    );
  }
}
