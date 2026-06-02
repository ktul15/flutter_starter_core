import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

void main() {
  group('AppTheme', () {
    test('light and dark derive matching brightness from seed', () {
      final light = AppTheme.light(seedColor: Colors.indigo);
      final dark = AppTheme.dark(seedColor: Colors.indigo);
      expect(light.colorScheme.brightness, Brightness.light);
      expect(dark.colorScheme.brightness, Brightness.dark);
      expect(light.useMaterial3, isTrue);
    });
  });

  group('ThemeModeController', () {
    test('defaults to system', () {
      expect(ThemeModeController().value, ThemeMode.system);
    });

    test('toggle flips light<->dark', () {
      final c = ThemeModeController(ThemeMode.light);
      c.toggle();
      expect(c.value, ThemeMode.dark);
      c.toggle();
      expect(c.value, ThemeMode.light);
    });

    test('toggle from system uses platform brightness', () {
      final c = ThemeModeController();
      c.toggle(platformIsDark: true);
      expect(c.value, ThemeMode.light);

      final c2 = ThemeModeController();
      c2.toggle(platformIsDark: false);
      expect(c2.value, ThemeMode.dark);
    });

    test('notifies listeners on change', () {
      final c = ThemeModeController(ThemeMode.light);
      var notified = 0;
      c.addListener(() => notified++);
      c.set(ThemeMode.dark);
      expect(notified, 1);
      expect(c.isDark, isTrue);
    });
  });
}
