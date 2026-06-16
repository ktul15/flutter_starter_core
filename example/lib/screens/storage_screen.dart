import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/storage_cubit.dart';

/// Demonstrates [TokenStore], [LocalPreferences], and [EnvConfigs] / [EnvConfig].
class StorageScreen extends StatelessWidget {
  const StorageScreen({
    super.key,
    required this.prefs,
    required this.tokenStore,
    required this.envConfigs,
  });

  final LocalPreferences prefs;
  final TokenStore tokenStore;
  final EnvConfigs envConfigs;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => StorageCubit(tokenStore, prefs),
      child: _StorageBody(envConfigs: envConfigs),
    );
  }
}

class _StorageBody extends StatefulWidget {
  const _StorageBody({required this.envConfigs});
  final EnvConfigs envConfigs;

  @override
  State<_StorageBody> createState() => _StorageBodyState();
}

class _StorageBodyState extends State<_StorageBody> {
  final _accessCtrl = TextEditingController(text: 'my-access-token-123');
  final _refreshCtrl = TextEditingController(text: 'my-refresh-token-456');
  final _keyCtrl = TextEditingController(text: 'demo_key');
  final _valueCtrl = TextEditingController(text: 'hello world');

  @override
  void dispose() {
    _accessCtrl.dispose();
    _refreshCtrl.dispose();
    _keyCtrl.dispose();
    _valueCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StorageCubit, StorageState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Storage')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── TokenStore ──────────────────────────────────────────────────
            _SectionHeader('TokenStore'),
            _kv('Access token', state.accessToken ?? '(none)'),
            _kv('Refresh token', state.refreshToken ?? '(none)'),
            const SizedBox(height: 12),
            TextField(
              controller: _accessCtrl,
              decoration:
                  const InputDecoration(labelText: 'Access token'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _refreshCtrl,
              decoration:
                  const InputDecoration(labelText: 'Refresh token'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => ctx.read<StorageCubit>().writeTokens(
                          _accessCtrl.text,
                          _refreshCtrl.text,
                        ),
                    child: const Text('Write'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ctx.read<StorageCubit>().clearTokens(),
                    child: const Text('Clear'),
                  ),
                ),
              ],
            ),

            const Divider(height: 40),

            // ── LocalPreferences ────────────────────────────────────────────
            _SectionHeader('LocalPreferences'),
            const Text(
              'Wraps SharedPreferences behind the AppPreferences interface. '
              'In production, swap with your own impl (e.g. Hive, Isar).',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _keyCtrl,
              decoration: const InputDecoration(labelText: 'Key'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _valueCtrl,
              decoration:
                  const InputDecoration(labelText: 'Value (string)'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: () => ctx
                        .read<StorageCubit>()
                        .writePref(_keyCtrl.text, _valueCtrl.text),
                    child: const Text('Write'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        ctx.read<StorageCubit>().readPref(_keyCtrl.text),
                    child: const Text('Read'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => ctx
                        .read<StorageCubit>()
                        .deletePref(_keyCtrl.text),
                    child: const Text('Delete'),
                  ),
                ),
              ],
            ),
            if (state.prefValue != null) ...[
              const SizedBox(height: 8),
              _kv('Read result', state.prefValue!),
            ],

            const Divider(height: 40),

            // ── EnvConfig ───────────────────────────────────────────────────
            _SectionHeader('EnvConfig'),
            _kv('Current environment', widget.envConfigs.current.name),
            _kv('Base URL', widget.envConfigs.config.baseUrl),
            _kv('isDev', widget.envConfigs.config.isDev.toString()),
            _kv('isProd', widget.envConfigs.config.isProd.toString()),
            const SizedBox(height: 8),
            Text(
              'All registered environments:',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            for (final env in Environment.values)
              _kv(
                env.name,
                widget.envConfigs.of(env)?.baseUrl ?? '(not configured)',
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

Widget _kv(String label, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
