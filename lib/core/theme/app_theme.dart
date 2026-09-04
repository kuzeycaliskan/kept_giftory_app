import 'package:flutter/material.dart';

/// Centralized theme. No ad-hoc colors/sizes elsewhere (CLAUDE.md §9);
/// components pull from here.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF6C4DF6);

  static ThemeData light() => ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seed),
        useMaterial3: true,
      );
}
