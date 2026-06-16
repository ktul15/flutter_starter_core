import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/analytics_cubit.dart';

/// Demonstrates [AnalyticsService] (with [NoOpAnalyticsService]) and
/// [CrashReporter] / [CrashReporterWiring].
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AnalyticsCubit(),
      child: const _AnalyticsBody(),
    );
  }
}

class _AnalyticsBody extends StatelessWidget {
  const _AnalyticsBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AnalyticsCubit, AnalyticsState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Analytics & Crash')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // ── AnalyticsService ──────────────────────────────────────
                  _Section('AnalyticsService (NoOpAnalyticsService)'),
                  const Text(
                    'NoOpAnalyticsService is the safe default. Replace it with '
                    'your Firebase Analytics / Mixpanel / Amplitude impl by '
                    'implementing AnalyticsService.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () =>
                            ctx.read<AnalyticsCubit>().trackEvent(),
                        child: const Text('trackEvent'),
                      ),
                      FilledButton(
                        onPressed: () =>
                            ctx.read<AnalyticsCubit>().setUser(),
                        child: const Text('setUser'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            ctx.read<AnalyticsCubit>().resetUser(),
                        child: const Text('resetUser'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            ctx.read<AnalyticsCubit>().setScreen(),
                        child: const Text('setCurrentScreen'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            ctx.read<AnalyticsCubit>().trackError(),
                        child: const Text('trackError'),
                      ),
                    ],
                  ),

                  const Divider(height: 32),

                  // ── CrashReporter ─────────────────────────────────────────
                  _Section('CrashReporter + CrashReporterWiring'),
                  const Text(
                    'Wire once in main() via CrashReporterWiring.attach(reporter). '
                    'All unhandled Flutter and Dart errors are routed automatically.',
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'void main() async {\n'
                      '  WidgetsFlutterBinding.ensureInitialized();\n'
                      '  CrashReporterWiring.attach(MyCrashlyticsImpl());\n'
                      '  runApp(const MyApp());\n'
                      '}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () =>
                        ctx.read<AnalyticsCubit>().recordCrash(),
                    child: const Text('Demo: recordError + log'),
                  ),
                ],
              ),
            ),

            // ── Call log ────────────────────────────────────────────────────
            const Divider(height: 1),
            Container(
              height: 180,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Call log',
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            ctx.read<AnalyticsCubit>().clearLog(),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                  Expanded(
                    child: state.callLog.isEmpty
                        ? Center(
                            child: Text(
                              'Tap a button above',
                              style:
                                  Theme.of(context).textTheme.bodySmall,
                            ),
                          )
                        : ListView.builder(
                            itemCount: state.callLog.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2,
                              ),
                              child: Text(
                                '→ ${state.callLog[i]}',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
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
      padding: const EdgeInsets.only(bottom: 8),
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
