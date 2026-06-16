import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

void main() {
  group('PermissionStatus sealed classes', () {
    test('PermissionGranted is PermissionStatus', () {
      expect(const PermissionGranted(), isA<PermissionStatus>());
    });

    test('PermissionDenied is PermissionStatus', () {
      expect(const PermissionDenied(), isA<PermissionStatus>());
    });

    test('PermissionPermanentlyDenied is PermissionStatus', () {
      expect(const PermissionPermanentlyDenied(), isA<PermissionStatus>());
    });

    test('PermissionRestricted is PermissionStatus', () {
      expect(const PermissionRestricted(), isA<PermissionStatus>());
    });
  });

  group('AppPermission enum', () {
    test('all values exist', () {
      expect(AppPermission.values, hasLength(9));
    });
  });
}
