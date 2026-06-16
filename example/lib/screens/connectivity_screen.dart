import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/connectivity_cubit.dart';

/// Demonstrates [ConnectivityChecker.isOnline] and [ConnectivityChecker.onStatusChange].
class ConnectivityScreen extends StatelessWidget {
  const ConnectivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ConnectivityCubit(),
      child: const _ConnectivityBody(),
    );
  }
}

class _ConnectivityBody extends StatelessWidget {
  const _ConnectivityBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityState>(
      builder: (ctx, state) {
        final cs = Theme.of(context).colorScheme;
        final statusColor = state.isOnline == null
            ? cs.surfaceContainerHighest
            : state.isOnline!
                ? cs.tertiary
                : cs.error;
        final onStatusColor = state.isOnline == null
            ? cs.onSurface
            : state.isOnline!
                ? cs.onTertiary
                : cs.onError;

        return Scaffold(
          appBar: AppBar(title: const Text('Connectivity')),
          body: Column(
            children: [
              // ── Status banner ───────────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                color: statusColor,
                child: Column(
                  children: [
                    Icon(
                      state.isOnline == null
                          ? Icons.help_outline
                          : state.isOnline!
                              ? Icons.wifi
                              : Icons.wifi_off,
                      size: 48,
                      color: onStatusColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.isOnline == null
                          ? 'Checking…'
                          : state.isOnline!
                              ? 'Online'
                              : 'Offline',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: onStatusColor),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonal(
                      onPressed: () =>
                          ctx.read<ConnectivityCubit>().checkNow(),
                      child: const Text('Check now  (isOnline)'),
                    ),
                  ],
                ),
              ),

              // ── Stream events ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'onStatusChange stream',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          ctx.read<ConnectivityCubit>().clearEvents(),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: state.events.isEmpty
                    ? Center(
                        child: Text(
                          'Toggle airplane mode to see events',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      )
                    : ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.events.length,
                        itemBuilder: (_, i) {
                          final e = state.events[i];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              e.online ? Icons.wifi : Icons.wifi_off,
                              color: e.online ? cs.tertiary : cs.error,
                              size: 20,
                            ),
                            title: Text(e.online ? 'Online' : 'Offline'),
                            subtitle: Text(
                              DateFormatter.formatDateTime(e.time),
                              style:
                                  Theme.of(context).textTheme.labelSmall,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
