import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/theme_cubit.dart';

/// Demonstrates [PersistentThemeModeController] — set(), toggle(), and
/// persistence across restarts.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key, required this.controller});

  final PersistentThemeModeController controller;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ThemeCubit(controller),
      child: const _ThemeBody(),
    );
  }
}

class _ThemeBody extends StatelessWidget {
  const _ThemeBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (ctx, mode) => Scaffold(
        appBar: AppBar(title: const Text('Theme')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _InfoBox(
              'PersistentThemeModeController extends ThemeModeController '
              '(a ValueNotifier<ThemeMode>) and persists the selected mode to '
              'LocalPreferences. The chosen mode survives app restarts.',
            ),
            const SizedBox(height: 24),

            Text(
              'Current mode',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            _ModeBadge(mode),
            const SizedBox(height: 24),

            Text(
              'controller.set(mode)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {mode},
              onSelectionChanged: (s) =>
                  ctx.read<ThemeCubit>().setMode(s.first),
            ),
            const SizedBox(height: 24),

            Text(
              'controller.toggle(platformIsDark: …)',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => ctx.read<ThemeCubit>().toggle(
                    platformIsDark:
                        MediaQuery.platformBrightnessOf(context) ==
                            Brightness.dark,
                  ),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Toggle light ↔ dark'),
            ),

            const Divider(height: 40),

            Text(
              'AppTheme.light / dark accept a seedColor — M3 ColorScheme is '
              'generated from it.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Colors.indigo,
                Colors.teal,
                Colors.deepOrange,
                Colors.pink,
                Colors.green,
                Colors.purple,
              ]
                  .map((c) => CircleAvatar(
                        radius: 16,
                        backgroundColor: c,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge(this.mode);
  final ThemeMode mode;

  @override
  Widget build(BuildContext context) {
    final (label, icon) = switch (mode) {
      ThemeMode.light => ('Light', Icons.light_mode),
      ThemeMode.dark => ('Dark', Icons.dark_mode),
      ThemeMode.system => ('System', Icons.brightness_auto),
    };
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
