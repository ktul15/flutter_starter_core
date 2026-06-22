import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

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

    test('pre-release suffix stripped — beta equals release', () {
      // "1.2.3-beta" must compare as "1.2.3", not as "1.2.0"
      const info = AppVersionInfo(
        currentVersion: '2.0.0-beta.1',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, isNot(VersionStatus.updateRequired));
    });

    test('build metadata stripped — 2.0.0+42 equals 2.0.0', () {
      const info = AppVersionInfo(
        currentVersion: '2.0.0+42',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.0',
      );
      expect(info.status, VersionStatus.upToDate);
    });

    test('pre-release below min triggers updateRequired', () {
      // "1.0.0-rc" compares as "1.0.0" which is < minRequired "1.0.1"
      const info = AppVersionInfo(
        currentVersion: '1.0.0-rc',
        latestVersion: '2.0.0',
        minRequiredVersion: '1.0.1',
      );
      expect(info.status, VersionStatus.updateRequired);
    });
  });
}
