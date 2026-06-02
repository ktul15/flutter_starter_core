import 'package:flutter/material.dart';

/// Holds and mutates the active [ThemeMode].
///
/// A plain [ValueNotifier] so it plugs into `ValueListenableBuilder` or any
/// state solution without forcing one. Pass `themeMode: controller.value` to
/// `MaterialApp` and rebuild on change. Persistence is [PER-PROJECT] — read the
/// stored mode and seed [ThemeModeController.new], then save on change.
class ThemeModeController extends ValueNotifier<ThemeMode> {
  ThemeModeController([super.initial = ThemeMode.system]);

  bool get isDark => value == ThemeMode.dark;

  void set(ThemeMode mode) => value = mode;

  /// Toggles between light and dark. From [ThemeMode.system], uses [platformIsDark]
  /// to decide the opposite (defaults to switching to dark).
  void toggle({bool platformIsDark = false}) {
    value = switch (value) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.light,
      ThemeMode.system => platformIsDark ? ThemeMode.light : ThemeMode.dark,
    };
  }
}
