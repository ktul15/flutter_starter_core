import 'package:flutter_test/flutter_test.dart';
import 'package:mobilions_core/mobilions_core.dart';

void main() {
  group('AppVersionInfo.status', () {
    test('upToDate when current == latest', () {
      const info = AppVersionInfo(
        currentVersion: '2.0.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.upToDate);
    });

    test('updateAvailable when current < latest but >= min', () {
      const info = AppVersionInfo(
        currentVersion: '1.5.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.updateAvailable);
    });

    test('updateRequired when current < min', () {
      const info = AppVersionInfo(
        currentVersion: '0.9.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.updateRequired);
    });

    test('upToDate when current > latest', () {
      // dev build ahead of store
      const info = AppVersionInfo(
        currentVersion: '2.1.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.upToDate);
    });

    test('patch version comparison correct', () {
      const info = AppVersionInfo(
        currentVersion: '1.0.1',
        latestVersion: '1.0.2',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.updateAvailable);
    });

    test('updateRequired on exact min boundary minus one patch', () {
      const info = AppVersionInfo(
        currentVersion: '1.0.0',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.1',
      );
      expect(info.status, VersionStatus.updateRequired);
    });
  });
}
