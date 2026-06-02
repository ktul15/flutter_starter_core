import 'package:flutter/material.dart';

/// Builds coherent light/dark [ThemeData] from a small brand token set.
///
/// No brand values are hard-coded — the consumer supplies a [seedColor] (and
/// optionally a [fontFamily]); Material 3 derives the rest via
/// [ColorScheme.fromSeed].
abstract final class AppTheme {
  /// Light theme seeded from [seedColor].
  static ThemeData light({
    required Color seedColor,
    String? fontFamily,
  }) =>
      _build(seedColor: seedColor, brightness: Brightness.light, fontFamily: fontFamily);

  /// Dark theme seeded from [seedColor].
  static ThemeData dark({
    required Color seedColor,
    String? fontFamily,
  }) =>
      _build(seedColor: seedColor, brightness: Brightness.dark, fontFamily: fontFamily);

  static ThemeData _build({
    required Color seedColor,
    required Brightness brightness,
    String? fontFamily,
  }) {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: true,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
