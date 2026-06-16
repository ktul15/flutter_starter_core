import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

void main() {
  group('Debouncer', () {
    test('fires action after delay', () {
      fakeAsync((async) {
        final debouncer = Debouncer(delay: const Duration(milliseconds: 300));
        var fired = 0;
        debouncer.run(() => fired++);
        async.elapse(const Duration(milliseconds: 300));
        expect(fired, 1);
        debouncer.dispose();
      });
    });

    test('cancels earlier call when run again within delay', () {
      fakeAsync((async) {
        final debouncer = Debouncer(delay: const Duration(milliseconds: 300));
        var fired = 0;
        debouncer.run(() => fired++);
        async.elapse(const Duration(milliseconds: 100));
        debouncer.run(() => fired++);
        async.elapse(const Duration(milliseconds: 300));
        expect(fired, 1);
        debouncer.dispose();
      });
    });

    test('cancel prevents action from firing', () {
      fakeAsync((async) {
        final debouncer = Debouncer(delay: const Duration(milliseconds: 300));
        var fired = 0;
        debouncer.run(() => fired++);
        debouncer.cancel();
        async.elapse(const Duration(milliseconds: 300));
        expect(fired, 0);
        debouncer.dispose();
      });
    });

    test('isPending is true within delay window', () {
      fakeAsync((async) {
        final debouncer = Debouncer(delay: const Duration(milliseconds: 300));
        debouncer.run(() {});
        expect(debouncer.isPending, isTrue);
        async.elapse(const Duration(milliseconds: 300));
        expect(debouncer.isPending, isFalse);
        debouncer.dispose();
      });
    });
  });
}
