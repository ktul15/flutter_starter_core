import 'package:flutter_test/flutter_test.dart';

// The showcase app requires async init (SharedPreferences, PersistentThemeModeController)
// before runApp, so widget tests should bootstrap via a testable sub-widget.
// This file is intentionally minimal — integration tests live in the client project.
void main() {
  test('placeholder', () {
    // Smoke test: verifies the test runner can execute Dart code.
    expect(1 + 1, 2);
  });
}
