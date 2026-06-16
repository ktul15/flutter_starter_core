import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';
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

    test('clear removes everything', () async {
      await prefs.setString('a', 'x');
      await prefs.setString('b', 'y');
      await prefs.clear();
      expect(await prefs.getString('a'), isNull);
      expect(await prefs.getString('b'), isNull);
    });

    test('containsKey', () async {
      expect(prefs.containsKey('new'), isFalse);
      await prefs.setString('new', '1');
      expect(prefs.containsKey('new'), isTrue);
    });
  });
}
