import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kept/core/theme/app_theme.dart';

void main() {
  // Regression: component-theme text styles must carry explicit sizes.
  // Deriving from ThemeData's raw textTheme (no geometry before build)
  // once dropped the app bar title to the 14sp default (design.md §3).
  final themes = [('light', AppTheme.light()), ('dark', AppTheme.dark())];
  for (final (name, theme) in themes) {
    group(name, () {
      test('app bar title has an explicit 20sp size', () {
        final style = theme.appBarTheme.titleTextStyle;
        expect(style?.fontSize, 20);
        expect(style?.fontWeight, FontWeight.w700);
      });

      test('tab labels carry explicit sizes', () {
        expect(theme.tabBarTheme.labelStyle?.fontSize, isNotNull);
        expect(theme.tabBarTheme.unselectedLabelStyle?.fontSize, isNotNull);
      });

      test('button labels carry explicit sizes', () {
        for (final buttonStyle in [
          theme.filledButtonTheme.style,
          theme.outlinedButtonTheme.style,
          theme.textButtonTheme.style,
        ]) {
          final resolved = buttonStyle?.textStyle?.resolve(const {});
          expect(resolved?.fontSize, isNotNull);
        }
      });
    });
  }
}
