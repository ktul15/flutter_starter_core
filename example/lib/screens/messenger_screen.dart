import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/messenger_cubit.dart';

/// Demonstrates all [AppMessenger] snackbar variants.
class MessengerScreen extends StatelessWidget {
  const MessengerScreen({super.key, required this.messenger});

  final AppMessenger messenger;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MessengerCubit(),
      child: _MessengerBody(messenger: messenger),
    );
  }
}

class _MessengerBody extends StatelessWidget {
  const _MessengerBody({required this.messenger});
  final AppMessenger messenger;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MessengerCubit, MessengerDemoState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Messenger')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'AppMessenger wraps a GlobalKey<ScaffoldMessengerState>. '
                'Wire the key to MaterialApp.scaffoldMessengerKey once, then '
                'inject AppMessenger anywhere — no BuildContext required.',
                style: TextStyle(fontSize: 12),
              ),
            ),

            const SizedBox(height: 24),
            Text(
              'Duration',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 2, label: Text('2 s')),
                ButtonSegment(value: 3, label: Text('3 s')),
                ButtonSegment(value: 5, label: Text('5 s')),
              ],
              selected: {state.duration.inSeconds},
              onSelectionChanged: (s) =>
                  ctx.read<MessengerCubit>().setDuration(s.first),
            ),

            const SizedBox(height: 24),
            Text(
              'Snackbar types',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),

            _SnackButton(
              label: 'showSuccess',
              color: Colors.green,
              onTap: () => messenger.showSuccess(
                'Operation completed successfully.',
                duration: state.duration,
              ),
            ),
            const SizedBox(height: 8),
            _SnackButton(
              label: 'showError',
              color: Colors.red,
              onTap: () => messenger.showError(
                'Something went wrong. Please try again.',
                duration: state.duration,
              ),
            ),
            const SizedBox(height: 8),
            _SnackButton(
              label: 'showInfo',
              color: Colors.blue,
              onTap: () => messenger.showInfo(
                'Your session will expire in 5 minutes.',
                duration: state.duration,
              ),
            ),
            const SizedBox(height: 8),
            _SnackButton(
              label: 'showWarning',
              color: Colors.amber,
              onTap: () => messenger.showWarning(
                'Low storage space — consider freeing up some space.',
                duration: state.duration,
              ),
            ),

            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: messenger.hideCurrentSnackBar,
              child: const Text('hideCurrentSnackBar'),
            ),

            const SizedBox(height: 32),
            Text(
              'Custom snackbar',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => messenger.showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber),
                      SizedBox(width: 8),
                      Text('Custom snackbar with any widget'),
                    ],
                  ),
                  duration: state.duration,
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(label: 'Undo', onPressed: () {}),
                ),
              ),
              icon: const Icon(Icons.star_outline),
              label: const Text('showSnackBar (custom)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnackButton extends StatelessWidget {
  const _SnackButton({
    required this.label,
    required this.color,
    required this.onTap,
  });
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 44),
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
