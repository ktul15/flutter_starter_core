import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/localization_cubit.dart';

/// Demonstrates [LocalizationConfig] — how to wire it into MaterialApp and
/// how the locale resolver works.
class LocalizationScreen extends StatelessWidget {
  const LocalizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LocalizationCubit(),
      child: const _LocalizationBody(),
    );
  }
}

class _LocalizationBody extends StatelessWidget {
  const _LocalizationBody();

  static const _availableDeviceLocales = [
    Locale('en'),
    Locale('en', 'US'),
    Locale('es'),
    Locale('es', 'MX'),
    Locale('fr'),
    Locale('de'),
    Locale('ja'),
    Locale('zh'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocalizationCubit, LocalizationDemoState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Localization')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── MaterialApp wiring code ─────────────────────────────────────
            Text(
              'Wire into MaterialApp',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "final l10n = LocalizationConfig(\n"
                "  supportedLocales: [Locale('en'), Locale('es')],\n"
                "  delegates: [AppLocalizations.delegate], // [PER-PROJECT]\n"
                ");\n\n"
                "MaterialApp(\n"
                "  supportedLocales: l10n.supportedLocales,\n"
                "  localizationsDelegates: l10n.allDelegates,\n"
                "  localeResolutionCallback: l10n.resolve,\n"
                ")",
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                    ),
              ),
            ),

            const Divider(height: 32),

            // ── Supported locales ───────────────────────────────────────────
            Text(
              'Supported locales',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: LocalizationCubit.config.supportedLocales
                  .map((l) => Chip(label: Text(l.toLanguageTag())))
                  .toList(),
            ),
            const SizedBox(height: 4),
            Text(
              'Fallback: ${LocalizationCubit.config.fallbackLocale.toLanguageTag()}',
              style: Theme.of(context).textTheme.bodySmall,
            ),

            const Divider(height: 32),

            // ── Resolver demo ───────────────────────────────────────────────
            Text(
              'resolve() demo',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            Text(
              'Pick a device locale to see which supported locale it resolves to.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Locale>(
              decoration:
                  const InputDecoration(labelText: 'Device locale'),
              initialValue: state.deviceLocale,
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('(null)'),
                ),
                ..._availableDeviceLocales.map(
                  (l) => DropdownMenuItem(
                    value: l,
                    child: Text(l.toLanguageTag()),
                  ),
                ),
              ],
              onChanged: (l) =>
                  ctx.read<LocalizationCubit>().resolve(l),
            ),
            if (state.resolvedLocale != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.arrow_forward, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Resolved: ${state.resolvedLocale!.toLanguageTag()}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ],

            const Divider(height: 32),

            Text(
              'allDelegates includes GlobalMaterialLocalizations, '
              'GlobalWidgetsLocalizations, and GlobalCupertinoLocalizations '
              'automatically — no manual import needed.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
