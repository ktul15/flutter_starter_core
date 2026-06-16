import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/version_cubit.dart';

/// Demonstrates [AppVersionChecker] and the [VersionStatus] enum.
class VersionScreen extends StatelessWidget {
  const VersionScreen({super.key, required this.client});

  final ApiClient client;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VersionCubit(client),
      child: const _VersionBody(),
    );
  }
}

class _VersionBody extends StatelessWidget {
  const _VersionBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VersionCubit, VersionState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Version')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Setup code ──────────────────────────────────────────────────
            _Section('Setup'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "final checker = AppVersionChecker(\n"
                "  client: apiClient,\n"
                "  endpoint: '/app/version',\n"
                ");\n\n"
                "// Backend must return:\n"
                '// { "latest_version": "2.0.0",\n'
                '//   "min_required_version": "1.5.0",\n'
                '//   "update_url": "https://..." }',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(fontFamily: 'monospace'),
              ),
            ),

            const Divider(height: 32),

            // ── VersionStatus enum ──────────────────────────────────────────
            _Section('VersionStatus — handle all three cases'),
            _StatusRow(
              VersionStatus.upToDate,
              'User is on latest — no action needed.',
              Colors.green,
              Icons.check_circle_outline,
            ),
            const SizedBox(height: 8),
            _StatusRow(
              VersionStatus.updateAvailable,
              'Newer version exists — show optional update banner.',
              Colors.orange,
              Icons.system_update_outlined,
            ),
            const SizedBox(height: 8),
            _StatusRow(
              VersionStatus.updateRequired,
              'Current < min required — show force-update dialog.',
              Colors.red,
              Icons.warning_amber_outlined,
            ),

            const Divider(height: 32),

            // ── Live check ──────────────────────────────────────────────────
            _Section('Live check'),
            const Text(
              "The demo hits httpbin.org which doesn't have a /app/version "
              "endpoint — you'll see a Failure result demonstrating the "
              'error-handling path.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            PrimaryButton(
              label: 'Run check()',
              isLoading: state.checking,
              onPressed: () => ctx.read<VersionCubit>().check(),
            ),
            if (state.result != null) ...[
              const SizedBox(height: 16),
              switch (state.result!) {
                Success(:final data) => _InfoTile(
                    Icons.check_circle,
                    'Up to date',
                    'Current: ${data.currentVersion} · Latest: ${data.latestVersion} · Status: ${data.status.name}',
                    Colors.green,
                  ),
                Failure(:final error) => _InfoTile(
                    Icons.error_outline,
                    'Check failed (expected in demo)',
                    error.message,
                    Colors.orange,
                  ),
              },
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow(this.status, this.description, this.color, this.icon);
  final VersionStatus status;
  final String description;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.name,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: color),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile(this.icon, this.title, this.subtitle, this.color);
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
