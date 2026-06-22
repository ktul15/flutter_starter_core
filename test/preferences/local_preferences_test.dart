import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalPreferences', () {
    late AppPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await LocalPreferences.create();
    });

    test('string round-trip', () async {
      await prefs.setString('k', 'hello');
      expect(await prefs.getString('k'), 'hello');
    });

    test('getString returns null when absent', () async {
      expect(await prefs.getString('missing'), isNull);
    });

    test('bool round-trip', () async {
      await prefs.setBool('flag', true);
      expect(await prefs.getBool('flag'), isTrue);
    });

    test('int round-trip', () async {
      await prefs.setInt('count', 42);
      expect(await prefs.getInt('count'), 42);
    });

    test('remove deletes key', () async {
      await prefs.setString('del', 'bye');
      await prefs.remove('del');
      expect(await prefs.getString('del'), isNull);
    });

    test('clear removes only prefixed keys', () async {
      await prefs.setString('a', 'x');
      await prefs.setString('b', 'y');
      // Simulate a key written directly to SharedPreferences by another lib
      final sp = await SharedPreferences.getInstance();
      await sp.setString('other_lib_key', 'safe');

      await prefs.clear();

      expect(await prefs.getString('a'), isNull);
      expect(await prefs.getString('b'), isNull);
      // Key from another library must NOT be touched
      expect(sp.getString('other_lib_key'), 'safe');
    });

    test('containsKey', () async {
      expect(await prefs.containsKey('new'), isFalse);
      await prefs.setString('new', '1');
      expect(await prefs.containsKey('new'), isTrue);
    });
  });
}
