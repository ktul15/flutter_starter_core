import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

ApiException _err([String msg = 'boom']) =>
    ApiException(type: ApiErrorType.network, message: msg);

void main() {
  group('initial state', () {
    test('empty, loadable, blank', () {
      const s = PaginationState<int>();
      expect(s.isEmpty, isTrue);
      expect(s.canLoadMore, isTrue);
      expect(s.isBlank, isTrue);
      expect(s.isInitialLoad, isFalse);
      expect(s.isInitialError, isFalse);
      expect(s.page, 0);
      expect(s.pageSize, 20);
    });
  });

  group('startLoading', () {
    test('sets isLoading, blocks canLoadMore, marks isInitialLoad', () {
      final s = const PaginationState<int>().startLoading();
      expect(s.isLoading, isTrue);
      expect(s.canLoadMore, isFalse);
      expect(s.isInitialLoad, isTrue);
    });

    test('clears previous error', () {
      final s = const PaginationState<int>().failure(_err()).startLoading();
      expect(s.error, isNull);
    });
  });

  group('startRefreshing', () {
    test('sets isRefreshing while keeping items', () {
      final base = const PaginationState<int>()
          .startLoading()
          .appendPage([1, 2, 3]);
      final s = base.startRefreshing();
      expect(s.isRefreshing, isTrue);
      expect(s.isLoading, isFalse);
      expect(s.items, [1, 2, 3]);
      expect(s.canLoadMore, isFalse);
      expect(s.isInitialLoad, isFalse); // items present → not initial
    });

    test('clears previous error', () {
      final s = const PaginationState<int>().failure(_err()).startRefreshing();
      expect(s.error, isNull);
    });
  });

  group('appendPage — offset mode', () {
    test('accumulates items and advances page', () {
      final s = const PaginationState<int>(pageSize: 3)
          .startLoading()
          .appendPage([1, 2, 3]); // full page → not at end
      expect(s.items, [1, 2, 3]);
      expect(s.page, 1);
      expect(s.isLoading, isFalse);
      expect(s.hasReachedEnd, isFalse);
    });

    test('detects end via short page', () {
      final s = const PaginationState<int>(pageSize: 3)
          .startLoading()
          .appendPage([1, 2]); // 2 < 3 → end
      expect(s.hasReachedEnd, isTrue);
      expect(s.canLoadMore, isFalse);
    });

    test('full page does not set hasReachedEnd', () {
      final s = const PaginationState<int>(pageSize: 3)
          .startLoading()
          .appendPage([1, 2, 3]);
      expect(s.hasReachedEnd, isFalse);
    });

    test('accumulates across multiple pages', () {
      final s = const PaginationState<int>()
          .startLoading()
          .appendPage([1, 2, 3])
          .startLoading()
          .appendPage([4, 5]);
      expect(s.items, [1, 2, 3, 4, 5]);
      expect(s.page, 2);
    });

    test('pageSize override applies to end detection', () {
      final s = const PaginationState<int>(pageSize: 20)
          .startLoading()
          .appendPage([1, 2, 3], pageSize: 3); // short vs override
      expect(s.hasReachedEnd, isFalse); // 3 == 3 → full page
    });
  });

  group('appendPage — hasMore flag', () {
    test('hasMore: false sets hasReachedEnd regardless of count', () {
      // Full page but API says no more
      final s = const PaginationState<int>(pageSize: 3)
          .startLoading()
          .appendPage([1, 2, 3], hasMore: false);
      expect(s.hasReachedEnd, isTrue);
    });

    test('hasMore: true keeps canLoadMore even on short page', () {
      final s = const PaginationState<int>(pageSize: 10)
          .startLoading()
          .appendPage([1, 2], hasMore: true); // short but hasMore
      expect(s.hasReachedEnd, isFalse);
      expect(s.canLoadMore, isTrue);
    });
  });

  group('appendPage — cursor mode', () {
    test('stores nextCursor from response', () {
      final s = const PaginationState<String>()
          .startLoading()
          .appendPage(['a', 'b'], hasMore: true, nextCursor: 'cursor_abc');
      expect(s.nextCursor, 'cursor_abc');
      expect(s.hasReachedEnd, isFalse);
    });

    test('null nextCursor with hasMore: false ends pagination', () {
      final s = const PaginationState<String>()
          .startLoading()
          .appendPage(['a'], hasMore: false, nextCursor: null);
      expect(s.nextCursor, isNull);
      expect(s.hasReachedEnd, isTrue);
    });
  });

  group('appendPage — refresh replaces items', () {
    test('startRefreshing + appendPage replaces, resets page to 1', () {
      final base = const PaginationState<int>()
          .startLoading()
          .appendPage([1, 2, 3])
          .startLoading()
          .appendPage([4, 5, 6]);
      expect(base.items, [1, 2, 3, 4, 5, 6]);
      expect(base.page, 2);

      final refreshed = base.startRefreshing().appendPage([10, 20, 30]);
      expect(refreshed.items, [10, 20, 30]); // replaced, not appended
      expect(refreshed.page, 1);
      expect(refreshed.isRefreshing, isFalse);
    });
  });

  group('failure', () {
    test('stores ApiException, keeps items', () {
      final err = _err('network');
      final s = const PaginationState<int>()
          .startLoading()
          .appendPage([1])
          .startLoading()
          .failure(err);
      expect(s.items, [1]);
      expect(s.error, err);
      expect(s.error!.type, ApiErrorType.network);
      expect(s.isLoading, isFalse);
    });

    test('isInitialError when no items loaded yet', () {
      final s = const PaginationState<int>().startLoading().failure(_err());
      expect(s.isInitialError, isTrue);
      expect(s.isInitialLoad, isFalse);
    });

    test('isInitialError false when items exist', () {
      final s = const PaginationState<int>()
          .appendPage([1])
          .startLoading()
          .failure(_err());
      expect(s.isInitialError, isFalse);
    });

    test('failure after refresh clears isRefreshing', () {
      final s = const PaginationState<int>()
          .appendPage([1])
          .startRefreshing()
          .failure(_err());
      expect(s.isRefreshing, isFalse);
      expect(s.items, [1]); // items preserved through failed refresh
    });
  });

  group('reset', () {
    test('returns blank state, retains pageSize', () {
      final s = const PaginationState<int>(pageSize: 50)
          .appendPage(List.generate(50, (i) => i))
          .reset();
      expect(s.items, isEmpty);
      expect(s.page, 0);
      expect(s.pageSize, 50);
      expect(s.isBlank, isTrue);
    });
  });

  group('cursor not mutated by non-appendPage transitions', () {
    test('startLoading preserves cursor', () {
      final s = const PaginationState<int>()
          .appendPage([1], hasMore: true, nextCursor: 'cur1')
          .startLoading();
      expect(s.nextCursor, 'cur1');
    });

    test('failure preserves cursor', () {
      final s = const PaginationState<int>()
          .appendPage([1], hasMore: true, nextCursor: 'cur1')
          .failure(_err());
      expect(s.nextCursor, 'cur1');
    });
  });
}
