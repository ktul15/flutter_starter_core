import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';
import 'package:mocktail/mocktail.dart';

class _MockConnectivity extends Mock implements Connectivity {}

void main() {
  late _MockConnectivity connectivity;
  late ConnectivityChecker checker;

  setUp(() {
    connectivity = _MockConnectivity();
    checker = ConnectivityChecker(connectivity: connectivity);
  });

  test('isOnline true when any transport present', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.wifi]);
    expect(await checker.isOnline, isTrue);
  });

  test('isOnline false when only none', () async {
    when(() => connectivity.checkConnectivity())
        .thenAnswer((_) async => [ConnectivityResult.none]);
    expect(await checker.isOnline, isFalse);
  });

  test('onResultChange suppresses duplicate transport lists', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => controller.stream);

    final emitted = <List<ConnectivityResult>>[];
    final sub = checker.onResultChange.listen(emitted.add);

    controller.add([ConnectivityResult.wifi]);
    controller.add([ConnectivityResult.wifi]); // duplicate — dropped
    // Order change only — still same set, must be dropped
    controller.add([ConnectivityResult.ethernet, ConnectivityResult.wifi]);
    controller.add([ConnectivityResult.wifi, ConnectivityResult.ethernet]);
    // Genuine change
    controller.add([ConnectivityResult.mobile]);
    await Future<void>.delayed(Duration.zero);

    expect(emitted.length, 3);
    expect(emitted[0], [ConnectivityResult.wifi]);
    expect(emitted[1], [ConnectivityResult.ethernet, ConnectivityResult.wifi]);
    expect(emitted[2], [ConnectivityResult.mobile]);
    await sub.cancel();
    await controller.close();
  });

  test('onStatusChange maps and de-duplicates transitions', () async {
    final controller = StreamController<List<ConnectivityResult>>();
    when(() => connectivity.onConnectivityChanged)
        .thenAnswer((_) => controller.stream);

    final emitted = <bool>[];
    final sub = checker.onStatusChange.listen(emitted.add);

    controller.add([ConnectivityResult.none]);
    controller.add([ConnectivityResult.none]); // duplicate, dropped
    controller.add([ConnectivityResult.mobile]);
    controller.add([ConnectivityResult.wifi]); // still online, dropped
    controller.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);

    expect(emitted, [false, true, false]);
    await sub.cancel();
    await controller.close();
  });
}
