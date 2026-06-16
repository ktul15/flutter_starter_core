import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

void main() {
  test('initial state is empty and loadable', () {
    const s = PaginationState<int>();
    expect(s.isEmpty, isTrue);
    expect(s.canLoadMore, isTrue);
    expect(s.page, 0);
  });

  test('startLoading sets flag and clears error', () {
    final s = const PaginationState<int>().failure('boom').startLoading();
    expect(s.isLoading, isTrue);
    expect(s.error, isNull);
    expect(s.canLoadMore, isFalse);
  });

  test('appendPage accumulates items and advances page', () {
    final s = const PaginationState<int>()
        .startLoading()
        .appendPage([1, 2, 3], pageSize: 3);
    expect(s.items, [1, 2, 3]);
    expect(s.page, 1);
    expect(s.isLoading, isFalse);
    expect(s.hasReachedEnd, isFalse);

    final s2 = s.startLoading().appendPage([4, 5], pageSize: 3);
    expect(s2.items, [1, 2, 3, 4, 5]);
    expect(s2.page, 2);
    expect(s2.hasReachedEnd, isTrue, reason: 'short page = end');
    expect(s2.canLoadMore, isFalse);
  });

  test('failure keeps items and records message', () {
    final s = const PaginationState<int>()
        .appendPage([1], pageSize: 10)
        .startLoading()
        .failure('network');
    expect(s.items, [1]);
    expect(s.error, 'network');
    expect(s.isLoading, isFalse);
  });

  test('reset returns to a fresh state', () {
    final s = const PaginationState<int>().appendPage([1, 2], pageSize: 2).reset();
    expect(s.items, isEmpty);
    expect(s.page, 0);
  });
}
