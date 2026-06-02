/// Immutable state for offset/page-based infinite scroll.
///
/// Framework-agnostic: hold one of these in whatever state solution you use,
/// call [startLoading] / [appendPage] / [failure] as a fetch progresses, and
/// drive a list + "load more" footer from the flags.
class PaginationState<T> {
  const PaginationState({
    this.items = const [],
    this.page = 0,
    this.isLoading = false,
    this.hasReachedEnd = false,
    this.error,
  });

  final List<T> items;

  /// Number of pages already loaded (also the next page's zero-based index).
  final int page;

  /// A fetch is in flight.
  final bool isLoading;

  /// The last page returned fewer than [pageSize] items — nothing more to load.
  final bool hasReachedEnd;

  /// Last error message, if the most recent fetch failed.
  final String? error;

  bool get isEmpty => items.isEmpty;

  /// `true` when another page may be requested (not loading, not at end).
  bool get canLoadMore => !isLoading && !hasReachedEnd;

  /// Marks a fetch as started, clearing any previous error.
  PaginationState<T> startLoading() => _copy(isLoading: true, clearError: true);

  /// Appends [newItems]; sets [hasReachedEnd] when the page was short.
  ///
  /// [pageSize] is the requested page size used to detect the final page.
  PaginationState<T> appendPage(List<T> newItems, {required int pageSize}) =>
      _copy(
        items: [...items, ...newItems],
        page: page + 1,
        isLoading: false,
        hasReachedEnd: newItems.length < pageSize,
      );

  /// Records a fetch failure without losing already-loaded [items].
  PaginationState<T> failure(String message) =>
      _copy(isLoading: false, error: message);

  /// Resets to an empty first-page state (pull-to-refresh).
  PaginationState<T> reset() => PaginationState<T>();

  PaginationState<T> _copy({
    List<T>? items,
    int? page,
    bool? isLoading,
    bool? hasReachedEnd,
    String? error,
    bool clearError = false,
  }) =>
      PaginationState<T>(
        items: items ?? this.items,
        page: page ?? this.page,
        isLoading: isLoading ?? this.isLoading,
        hasReachedEnd: hasReachedEnd ?? this.hasReachedEnd,
        error: clearError ? null : (error ?? this.error),
      );
}
