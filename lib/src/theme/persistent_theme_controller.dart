import 'package:flutter/material.dart';

import '../preferences/app_preferences.dart';
import 'theme_mode_controller.dart';

/// [ThemeModeController] that automatically persists the selected mode via
/// [AppPreferences].
///
/// Use this instead of the base [ThemeModeController] whenever theme preference
/// should survive app restarts.
///
/// ```dart
/// // In main(), after initialising AppPreferences:
/// final prefs = await LocalPreferences.create();
/// final theme = await PersistentThemeModeController.create(prefs);
///
/// runApp(
///   ValueListenableBuilder(
///     valueListenable: theme,
///     builder: (_, mode, __) => MaterialApp(
///       themeMode: mode,
///       theme: AppTheme.light(seedColor: Colors.indigo),
///       darkTheme: AppTheme.dark(seedColor: Colors.indigo),
///     ),
///   ),
/// );
/// ```
class PersistentThemeModeController extends ThemeModeController {
  PersistentThemeModeController._(super.initial, this._prefs) {
    addListener(_save);
  }

  final AppPreferences _prefs;

  static const _key = 'theme_mode';

  /// Reads the persisted mode from [prefs] and returns a ready-to-use
  /// controller. Falls back to [ThemeMode.system] if nothing is stored.
  static Future<PersistentThemeModeController> create(
    AppPreferences prefs,
  ) async {
    final stored = await prefs.getString(_key);
    return PersistentThemeModeController._(_fromString(stored), prefs);
  }

  void _save() {
    // ValueNotifier listeners are synchronous — can't await. A write failure
    // is non-fatal: the mode shows correctly this session but reverts to
    // ThemeMode.system on next cold start.
    _prefs.setString(_key, _toString(value)).catchError(
      (Object e) => debugPrint('[flutter_starter_core] theme save failed: $e'),
    );
  }

  static ThemeMode _fromString(String? s) => switch (s) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };

  static String _toString(ThemeMode m) => switch (m) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      };
}
