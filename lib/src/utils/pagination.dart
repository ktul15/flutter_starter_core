import '../network/api_exception.dart';

/// Immutable state for offset/page-based or cursor-based infinite scroll.
///
/// Framework-agnostic: hold one of these in whatever state solution you use,
/// call [startLoading] / [startRefreshing] / [appendPage] / [failure] as a
/// fetch progresses, and drive a list + footer from the flags.
///
/// **Offset mode** (default):
/// ```dart
/// emit(state.startLoading());
/// final items = await api.getPage(state.page, size: 20);
/// emit(state.appendPage(items));
/// ```
///
/// **Cursor mode**: always pass `nextCursor` from the API response:
/// ```dart
/// emit(state.startLoading());
/// final res = await api.getPage(after: state.nextCursor);
/// emit(state.appendPage(res.items, hasMore: res.hasMore, nextCursor: res.next));
/// ```
class PaginationState<T> {
  const PaginationState({
    this.items = const [],
    this.page = 0,
    this.pageSize = 20,
    this.isLoading = false,
    this.isRefreshing = false,
    this.hasReachedEnd = false,
    this.error,
    this.nextCursor,
  });

  final List<T> items;

  /// Pages already loaded (next page index in offset mode).
  final int page;

  /// Page size used for end-of-list detection when [appendPage] has no [hasMore].
  final int pageSize;

  /// A load-more fetch is in flight (footer spinner).
  final bool isLoading;

  /// A pull-to-refresh fetch is in flight (top spinner, items still visible).
  final bool isRefreshing;

  /// No more pages available.
  final bool hasReachedEnd;

  /// Error from the most recent failed fetch; cleared on next [startLoading] /
  /// [startRefreshing] / successful [appendPage].
  final ApiException? error;

  /// Opaque cursor for the next page (cursor-based APIs only).
  final String? nextCursor;

  // ── Computed ──────────────────────────────────────────────────────────────

  bool get isEmpty => items.isEmpty;

  /// Another page can be requested right now (no in-flight request, no error,
  /// list not exhausted). Check [canRetry] for the error-retry case.
  bool get canLoadMore =>
      !isLoading && !isRefreshing && !hasReachedEnd && error == null;

  /// A failed fetch can be retried (error present, no in-flight request, list
  /// not exhausted). Distinct from [canLoadMore] so UIs can show a retry button
  /// instead of a load-more trigger.
  bool get canRetry =>
      !isLoading && !isRefreshing && !hasReachedEnd && error != null;

  /// Items are empty and the first fetch is in flight — show a full skeleton.
  bool get isInitialLoad => items.isEmpty && isLoading && !isRefreshing;

  /// First fetch failed — no items to show, show an error view.
  bool get isInitialError =>
      items.isEmpty && !isLoading && !isRefreshing && error != null;

  /// Nothing loaded yet and no fetch running — show an empty-state illustration.
  bool get isBlank =>
      items.isEmpty && !isLoading && !isRefreshing && error == null;

  // ── Transitions ───────────────────────────────────────────────────────────

  /// Marks a load-more fetch as started; clears any previous error.
  PaginationState<T> startLoading() => _copy(isLoading: true, clearError: true);

  /// Marks a pull-to-refresh fetch as started; clears any previous error.
  /// Items remain visible behind the refresh indicator.
  PaginationState<T> startRefreshing() =>
      _copy(isRefreshing: true, clearError: true);

  /// Appends [newItems] on load-more; **replaces** items on refresh.
  ///
  /// End detection (priority order):
  /// 1. [hasMore] — explicit flag from the API response.
  /// 2. `newItems.length < pageSize` — fallback for offset APIs that don't
  ///    return a `hasMore` field.
  ///
  /// For cursor-based APIs always pass [nextCursor] from the response; `null`
  /// signals the cursor is exhausted.
  PaginationState<T> appendPage(
    List<T> newItems, {
    int? pageSize,
    bool? hasMore,
    String? nextCursor,
  }) {
    final size = pageSize ?? this.pageSize;
    final reachedEnd =
        hasMore != null ? !hasMore : newItems.length < size;
    final mergedItems = List<T>.unmodifiable(
        isRefreshing ? newItems : [...items, ...newItems]);

    return PaginationState<T>(
      items: mergedItems,
      page: isRefreshing ? 1 : page + 1,
      pageSize: size,
      isLoading: false,
      isRefreshing: false,
      hasReachedEnd: reachedEnd,
      nextCursor: nextCursor,
    );
  }

  /// Records a fetch failure without losing already-loaded [items].
  PaginationState<T> failure(ApiException exception) =>
      _copy(isLoading: false, isRefreshing: false, error: exception);

  /// Resets to an empty first-page state; retains [pageSize].
  PaginationState<T> reset() => PaginationState<T>(pageSize: pageSize);

  // ── Internal ──────────────────────────────────────────────────────────────

  PaginationState<T> _copy({
    List<T>? items,
    int? page,
    int? pageSize,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasReachedEnd,
    ApiException? error,
    bool clearError = false,
  }) =>
      PaginationState<T>(
        items: items ?? this.items,
        page: page ?? this.page,
        pageSize: pageSize ?? this.pageSize,
        isLoading: isLoading ?? this.isLoading,
        isRefreshing: isRefreshing ?? this.isRefreshing,
        hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
        error: clearError ? null : (error ?? this.error),
        nextCursor: nextCursor, // cursor only changes via appendPage
      );
}
