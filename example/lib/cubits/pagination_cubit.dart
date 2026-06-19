import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

/// Wraps [PaginationState] to demonstrate offset-based infinite scroll.
///
/// The cubit owns the fetch logic; the screen owns the [ScrollController].
class PaginationCubit extends Cubit<PaginationState<String>> {
  PaginationCubit() : super(const PaginationState()) {
    scheduleMicrotask(loadPage);
  }

  static const _pageSize = 5;
  static const _totalItems = 23;

  Future<void> loadPage() async {
    if (!state.canLoadMore) return;
    emit(state.startLoading());

    await Future<void>.delayed(const Duration(milliseconds: 800));

    final start = state.page * _pageSize;
    if (start >= _totalItems) {
      emit(state.appendPage([]));
      return;
    }

    final end = (start + _pageSize).clamp(0, _totalItems);
    final newItems = List.generate(
      end - start,
      (i) => 'Item ${start + i + 1} of $_totalItems',
    );
    emit(state.appendPage(newItems));
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    emit(state.startRefreshing());

    await Future<void>.delayed(const Duration(milliseconds: 800));

    // Refresh always returns the first page; appendPage replaces items
    // because isRefreshing is true.
    final newItems = List.generate(
      _pageSize,
      (i) => 'Item ${i + 1} of $_totalItems',
    );
    emit(state.appendPage(newItems));
  }
}
