import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/utils_cubit.dart';

/// Demonstrates [Debouncer], [DateFormatter], and [HapticService].
class UtilsScreen extends StatelessWidget {
  const UtilsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => UtilsCubit(),
      child: const _UtilsBody(),
    );
  }
}

class _UtilsBody extends StatefulWidget {
  const _UtilsBody();

  @override
  State<_UtilsBody> createState() => _UtilsBodyState();
}

class _UtilsBodyState extends State<_UtilsBody> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final fiveMinAgo = now.subtract(const Duration(minutes: 5));
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final twoMonthsAgo = now.subtract(const Duration(days: 65));

    return BlocBuilder<UtilsCubit, UtilsState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Utils')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Debouncer ───────────────────────────────────────────────────
            _SectionTitle('Debouncer (delay: 600ms)'),
            Text(
              'Type quickly — only the last call within 600 ms fires. '
              'Ideal for search-as-you-type.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchCtrl,
              onChanged: (_) =>
                  ctx.read<UtilsCubit>().onTextChanged(),
              decoration: const InputDecoration(
                labelText: 'Search field',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _CountChip('Raw keystrokes', state.rawCount),
                const SizedBox(width: 12),
                _CountChip(
                  'Debounced fires',
                  state.debouncedCount,
                  highlight: true,
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {
                ctx.read<UtilsCubit>().reset();
                _searchCtrl.clear();
              },
              child: const Text('Reset'),
            ),

            const Divider(height: 40),

            // ── DateFormatter ───────────────────────────────────────────────
            _SectionTitle('DateFormatter (static methods)'),
            _DateRow('relative — just now', DateFormatter.relative(now)),
            _DateRow(
              'relative — 5 min ago',
              DateFormatter.relative(fiveMinAgo),
            ),
            _DateRow(
              'relative — 3 days ago',
              DateFormatter.relative(threeDaysAgo),
            ),
            _DateRow(
              'relative — 2 months ago (falls back to date)',
              DateFormatter.relative(twoMonthsAgo),
            ),
            const SizedBox(height: 8),
            _DateRow('formatDate', DateFormatter.formatDate(now)),
            _DateRow('formatTime', DateFormatter.formatTime(now)),
            _DateRow(
              'formatDateTime',
              DateFormatter.formatDateTime(now),
            ),

            const Divider(height: 40),

            // ── HapticService ───────────────────────────────────────────────
            _SectionTitle('HapticService'),
            Text(
              'Haptic feedback is device-specific. Test on a real device.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _HapticButton('light', HapticService.light),
                _HapticButton('medium', HapticService.medium),
                _HapticButton('heavy', HapticService.heavy),
                _HapticButton('selection', HapticService.selection),
                _HapticButton('success', HapticService.success),
                _HapticButton('error', HapticService.error),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _CountChip extends StatelessWidget {
  const _CountChip(this.label, this.count, {this.highlight = false});
  final String label;
  final int count;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor:
          highlight ? Theme.of(context).colorScheme.primaryContainer : null,
      label: Text('$label: $count'),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(fontFamily: 'monospace'),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _HapticButton extends StatelessWidget {
  const _HapticButton(this.label, this.action);
  final String label;
  final Future<void> Function() action;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () => action(),
      child: Text(label),
    );
  }
}
