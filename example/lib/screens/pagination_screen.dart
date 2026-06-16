import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/pagination_cubit.dart';

/// Demonstrates [PaginationState] with a fake infinite scroll list.
class PaginationScreen extends StatelessWidget {
  const PaginationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PaginationCubit(),
      child: const _PaginationBody(),
    );
  }
}

class _PaginationBody extends StatefulWidget {
  const _PaginationBody();

  @override
  State<_PaginationBody> createState() => _PaginationBodyState();
}

class _PaginationBodyState extends State<_PaginationBody> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
        _scrollCtrl.position.maxScrollExtent - 80) {
      context.read<PaginationCubit>().loadPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PaginationCubit, PaginationState<String>>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Pagination')),
        body: Column(
          children: [
            // ── State debug bar ─────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              color:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  _Badge('page ${state.page}'),
                  const SizedBox(width: 8),
                  _Badge('${state.items.length} items'),
                  const SizedBox(width: 8),
                  if (state.isLoading)
                    _Badge('loading', highlight: true),
                  if (state.hasReachedEnd)
                    _Badge('end reached', highlight: true),
                  if (state.error != null)
                    _Badge('error', highlight: true),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────────────────────
            Expanded(
              child: RefreshIndicator(
                onRefresh: () =>
                    ctx.read<PaginationCubit>().refresh(),
                child: state.isEmpty && !state.isLoading
                    ? const EmptyState(
                        title: 'No items',
                        message: 'Pull to refresh',
                        icon: Icons.list_alt_outlined,
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        itemCount: state.items.length + 1,
                        itemBuilder: (context, i) {
                          if (i == state.items.length) {
                            return _Footer(
                              state: state,
                              onLoadMore: () => ctx
                                  .read<PaginationCubit>()
                                  .loadPage(),
                            );
                          }
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('${i + 1}'),
                            ),
                            title: Text(state.items[i]),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.state, required this.onLoadMore});
  final PaginationState<String> state;
  final VoidCallback onLoadMore;

  @override
  Widget build(BuildContext context) {
    if (state.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: AppLoader(size: 24, message: 'Loading more…'),
      );
    }
    if (state.hasReachedEnd) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Text(
            'All ${state.items.length} items loaded',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      );
    }
    if (state.error != null) {
      return ErrorStateView(message: state.error!, onRetry: onLoadMore);
    }
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: OutlinedButton(
          onPressed: onLoadMore,
          child: const Text('Load more'),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.label, {this.highlight = false});
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: highlight
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context)
              .colorScheme
              .outline
              .withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: highlight
                  ? Theme.of(context).colorScheme.onPrimary
                  : null,
            ),
      ),
    );
  }
}
