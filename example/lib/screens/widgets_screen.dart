import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/widgets_cubit.dart';

/// Showcases every exported widget: buttons, inputs, loaders, states, OTP,
/// and network image.
class WidgetsScreen extends StatelessWidget {
  const WidgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WidgetsCubit(),
      child: const _WidgetsBody(),
    );
  }
}

class _WidgetsBody extends StatefulWidget {
  const _WidgetsBody();

  @override
  State<_WidgetsBody> createState() => _WidgetsBodyState();
}

class _WidgetsBodyState extends State<_WidgetsBody> {
  final _textCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WidgetsCubit, WidgetsState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Widgets')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── PrimaryButton ───────────────────────────────────────────────
            _Section('PrimaryButton'),
            PrimaryButton(label: 'Normal', onPressed: () {}),
            const SizedBox(height: 8),
            PrimaryButton(
              label: state.isButtonLoading
                  ? 'Working…'
                  : 'Tap to simulate loading',
              isLoading: state.isButtonLoading,
              onPressed: () =>
                  ctx.read<WidgetsCubit>().simulateLoad(),
            ),
            const SizedBox(height: 8),
            const PrimaryButton(
              label: 'Disabled (onPressed: null)',
              onPressed: null,
            ),

            const Divider(height: 32),

            // ── AppTextField ────────────────────────────────────────────────
            _Section('AppTextField'),
            AppTextField(
              controller: _textCtrl,
              label: 'Username',
              prefixIcon: Icons.person_outline,
              validator: Validators.required(),
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: TextEditingController(),
              label: 'Search',
              prefixIcon: Icons.search,
              keyboardType: TextInputType.text,
            ),

            const Divider(height: 32),

            // ── PasswordField ───────────────────────────────────────────────
            _Section('PasswordField'),
            PasswordField(
              controller: _passCtrl,
              validator: Validators.password(),
            ),

            const Divider(height: 32),

            // ── AppLoader ───────────────────────────────────────────────────
            _Section('AppLoader'),
            const AppLoader(),
            const SizedBox(height: 8),
            const AppLoader(size: 48, message: 'Loading data…'),

            const Divider(height: 32),

            // ── SkeletonBox ─────────────────────────────────────────────────
            _Section('SkeletonBox'),
            const SkeletonBox(height: 16, width: 200),
            const SizedBox(height: 8),
            const SkeletonBox(height: 12, width: 140),
            const SizedBox(height: 8),
            const SkeletonBox(height: 80),
            const SizedBox(height: 8),
            const Row(
              children: [
                SkeletonBox(height: 48, width: 48, borderRadius: 24),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonBox(height: 14),
                      SizedBox(height: 6),
                      SkeletonBox(height: 10, width: 100),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 32),

            // ── EmptyState ──────────────────────────────────────────────────
            _Section('EmptyState'),
            const SizedBox(
              height: 200,
              child: EmptyState(
                title: 'No items yet',
                message: 'Add your first item to get started.',
                icon: Icons.inbox_outlined,
              ),
            ),

            const Divider(height: 32),

            // ── ErrorStateView ──────────────────────────────────────────────
            _Section('ErrorStateView'),
            SizedBox(
              height: 200,
              child: ErrorStateView(
                message:
                    'Failed to load data. Check your connection and try again.',
                onRetry: () {},
              ),
            ),
            const SizedBox(height: 16),
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
