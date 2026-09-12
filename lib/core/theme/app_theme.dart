import 'package:flutter/material.dart';
import 'package:kept/core/theme/kept_tokens.dart';

/// Kept Design Language v1 (design.md). The ONLY file where hex colors live.
///
/// Neutral surfaces (no Material tonal wash), violet as the single sparing
/// accent, red reserved for destructive actions. Light and dark are both
/// first-class.
class AppTheme {
  const AppTheme._();

  // ── Brand palette ─────────────────────────────────────────────────────────
  static const Color _violet = Color(0xFF6C4DF6);
  static const Color _violetLight = Color(0xFF9B7BFF); // dark-mode primary

  // Light neutrals
  static const Color _inkLight = Color(0xFF17131F);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _containerLight = Color(0xFFF4F3F7);
  static const Color _outlineLight = Color(0xFFE7E5EC);
  static const Color _mutedLight = Color(0xFF6E6880);

  // Dark neutrals (near-black with a hint of the brand's warmth)
  static const Color _inkDark = Color(0xFFECEAF1);
  static const Color _surfaceDark = Color(0xFF141218);
  static const Color _containerDark = Color(0xFF1F1C26);
  static const Color _outlineDark = Color(0xFF322E3C);
  static const Color _mutedDark = Color(0xFF9A94A8);

  static ThemeData light() => _build(
    ColorScheme.fromSeed(seedColor: _violet).copyWith(
      primary: _violet,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFEAE4FF),
      onPrimaryContainer: const Color(0xFF3A2A85),
      surface: _surfaceLight,
      onSurface: _inkLight,
      surfaceContainerLowest: _surfaceLight,
      surfaceContainerLow: _containerLight,
      surfaceContainer: _containerLight,
      surfaceContainerHigh: _containerLight,
      surfaceContainerHighest: _containerLight,
      onSurfaceVariant: _mutedLight,
      outline: _mutedLight,
      outlineVariant: _outlineLight,
    ),
  );

  static ThemeData dark() => _build(
    ColorScheme.fromSeed(
      seedColor: _violet,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _violetLight,
      onPrimary: const Color(0xFF241566),
      primaryContainer: const Color(0xFF443397),
      onPrimaryContainer: const Color(0xFFE5DEFF),
      surface: _surfaceDark,
      onSurface: _inkDark,
      surfaceContainerLowest: _surfaceDark,
      surfaceContainerLow: _containerDark,
      surfaceContainer: _containerDark,
      surfaceContainerHigh: _containerDark,
      surfaceContainerHighest: _containerDark,
      onSurfaceVariant: _mutedDark,
      outline: _mutedDark,
      outlineVariant: _outlineDark,
    ),
  );

  static ThemeData _build(ColorScheme scheme) {
    final base = ThemeData(colorScheme: scheme, useMaterial3: true);
    final pillShape = RoundedRectangleBorder(borderRadius: KeptRadius.pillAll);

    return base.copyWith(
      scaffoldBackgroundColor: scheme.surface,

      // Flat app bar: surface color, no elevation, no scroll tint.
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        elevation: 0,
        indicatorColor: scheme.primaryContainer,
        surfaceTintColor: Colors.transparent,
      ),

      // Pill buttons with weight-based hierarchy (design.md §4).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: pillShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(
            horizontal: KeptSpacing.xl,
            vertical: KeptSpacing.md,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: pillShape,
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(
            horizontal: KeptSpacing.xl,
            vertical: KeptSpacing.md,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: pillShape,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      // Subtle filled inputs: no border, violet hairline on focus.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: KeptRadius.controlAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KeptRadius.controlAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KeptRadius.controlAll,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KeptRadius.controlAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: KeptRadius.controlAll,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
      ),

      // Flat outlined cards — reserved for featured content, never stacks.
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: KeptRadius.cardAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        margin: const EdgeInsets.symmetric(vertical: KeptSpacing.xs),
      ),

      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(iconColor: scheme.onSurfaceVariant),

      chipTheme: base.chipTheme.copyWith(
        shape: RoundedRectangleBorder(
          borderRadius: KeptRadius.pillAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        backgroundColor: scheme.surface,
        side: BorderSide(color: scheme.outlineVariant),
      ),

      tabBarTheme: base.tabBarTheme.copyWith(
        labelColor: scheme.onSurface,
        unselectedLabelColor: scheme.onSurfaceVariant,
        indicatorColor: scheme.primary,
        dividerColor: scheme.outlineVariant,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: KeptRadius.controlAll),
      ),

      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KeptRadius.sheet - 4),
        ),
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: KeptRadius.sheetTop),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: scheme.primaryContainer,
          selectedForegroundColor: scheme.onPrimaryContainer,
          side: BorderSide(color: scheme.outlineVariant),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: scheme.primary),
    );
  }
}
