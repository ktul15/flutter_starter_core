import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/permissions_cubit.dart';

/// Demonstrates [AppPermissions] — check, request, and open settings.
class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PermissionsCubit(),
      child: const _PermissionsBody(),
    );
  }
}

class _PermissionsBody extends StatelessWidget {
  const _PermissionsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PermissionsCubit, PermissionsState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(
          title: const Text('Permissions'),
          actions: [
            TextButton(
              onPressed: state.loading
                  ? null
                  : () => ctx.read<PermissionsCubit>().checkAll(),
              child: const Text('Check all'),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Permissions require a real device or physical simulator. '
                'Results may vary in the iOS/Android simulators.',
                style: TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              child: ListView(
                children: AppPermission.values.map((p) {
                  final status = state.statuses[p];
                  return ListTile(
                    title: Text(p.name),
                    subtitle: status != null
                        ? Text(
                            _statusLabel(status),
                            style: TextStyle(
                              color: _statusColor(context, status),
                            ),
                          )
                        : const Text('not checked'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Check',
                          onPressed: () =>
                              ctx.read<PermissionsCubit>().check(p),
                          icon: const Icon(
                            Icons.info_outline,
                            size: 20,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Request',
                          onPressed: () =>
                              ctx.read<PermissionsCubit>().request(p),
                          icon: const Icon(
                            Icons.lock_open_outlined,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton.icon(
                onPressed: () =>
                    ctx.read<PermissionsCubit>().openSettings(),
                icon: const Icon(Icons.settings_outlined),
                label: const Text('Open app settings'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _statusLabel(PermissionStatus s) => switch (s) {
        PermissionGranted() => 'Granted',
        PermissionDenied() => 'Denied',
        PermissionPermanentlyDenied() => 'Permanently denied',
        PermissionRestricted() => 'Restricted',
      };

  Color _statusColor(BuildContext context, PermissionStatus s) {
    final cs = Theme.of(context).colorScheme;
    return switch (s) {
      PermissionGranted() => cs.tertiary,
      PermissionDenied() => cs.error,
      PermissionPermanentlyDenied() => cs.error,
      PermissionRestricted() => cs.secondary,
    };
  }
}
