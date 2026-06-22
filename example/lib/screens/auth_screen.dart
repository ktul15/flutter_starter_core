import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/auth/flow_a_cubit.dart';
import '../cubits/auth/flow_b_cubit.dart';
import '../cubits/auth/login_cubit.dart';
import '../cubits/snack.dart';

/// Demonstrates all auth flows supported by [AuthService].
///
/// - **Login** tab: standard email + password sign-in.
/// - **Flow A** tab: register() → backend sends OTP → verifyOtp().
/// - **Flow B** tab: sendOtp() → verifyOtpOnly() → register().
class AuthScreen extends StatelessWidget {
  const AuthScreen({
    super.key,
    required this.auth,
    required this.tokenStore,
  });

  final AuthService auth;
  final TokenStore tokenStore;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Auth'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Login'),
              Tab(text: 'Flow A'),
              Tab(text: 'Flow B'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            BlocProvider(
              create: (_) => LoginCubit(auth),
              child: const _LoginTabBody(),
            ),
            BlocProvider(
              create: (_) => FlowACubit(auth),
              child: const _FlowATabBody(),
            ),
            BlocProvider(
              create: (_) => FlowBCubit(auth),
              child: const _FlowBTabBody(),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Login tab ────────────────────────────────────────────────────────────────

class _LoginTabBody extends StatefulWidget {
  const _LoginTabBody();

  @override
  State<_LoginTabBody> createState() => _LoginTabBodyState();
}

class _LoginTabBodyState extends State<_LoginTabBody> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'user@example.com');
  final _password = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listenWhen: (prev, curr) =>
          curr.snack != null && !identical(curr.snack, prev.snack),
      listener: (ctx, state) => dispatchSnack(ctx, state.snack!),
      builder: (ctx, state) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _email,
                  label: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.compose([
                    Validators.required(),
                    Validators.email(),
                  ]),
                ),
                const SizedBox(height: 16),
                PasswordField(
                  controller: _password,
                  validator: Validators.password(),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Login',
                  isLoading: state.loading,
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) return;
                    ctx.read<LoginCubit>().login(
                          _email.text.trim(),
                          _password.text,
                        );
                  },
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ctx.read<LoginCubit>().logout(),
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
          if (state.statusText != null) ...[
            const SizedBox(height: 24),
            _StatusCard(state.statusText!),
          ],
        ],
      ),
    );
  }
}

// ─── Flow A: register → OTP ───────────────────────────────────────────────────

class _FlowATabBody extends StatefulWidget {
  const _FlowATabBody();

  @override
  State<_FlowATabBody> createState() => _FlowATabBodyState();
}

class _FlowATabBodyState extends State<_FlowATabBody> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController(text: 'John Doe');
  final _email = TextEditingController(text: 'john@example.com');
  final _password = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlowACubit, FlowAState>(
      listenWhen: (prev, curr) =>
          curr.snack != null && !identical(curr.snack, prev.snack),
      listener: (ctx, state) => dispatchSnack(ctx, state.snack!),
      builder: (ctx, state) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _InfoCard(
            'Flow A: register() → backend sends OTP → verifyOtp()',
            'Use when your backend automatically emails an OTP after registration.',
          ),
          const SizedBox(height: 16),
          if (!state.showOtp) ...[
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _name,
                    label: 'Full name',
                    prefixIcon: Icons.person_outline,
                    validator: Validators.required(),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _email,
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.compose([
                      Validators.required(),
                      Validators.email(),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  PasswordField(
                    controller: _password,
                    validator: Validators.password(),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Register',
                    isLoading: state.loading,
                    onPressed: () {
                      if (!_formKey.currentState!.validate()) return;
                      ctx.read<FlowACubit>().register(
                            _name.text.trim(),
                            _email.text.trim(),
                            _password.text,
                          );
                    },
                  ),
                ],
              ),
            ),
          ] else ...[
            Text(
              'Enter the 6-digit OTP sent to ${state.email}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: OtpField(
                length: 6,
                autoFocus: false,
                onCompleted: (otp) =>
                    ctx.read<FlowACubit>().updateOtp(otp),
                onChanged: (v) => ctx.read<FlowACubit>().updateOtp(v),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Verify OTP',
              isLoading: state.loading,
              onPressed: state.currentOtp.length == 6
                  ? () => ctx.read<FlowACubit>().verifyOtp()
                  : null,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ctx.read<FlowACubit>().resendOtp(),
              child: const Text('Resend OTP'),
            ),
          ],
          if (state.statusText != null) ...[
            const SizedBox(height: 24),
            _StatusCard(state.statusText!),
          ],
        ],
      ),
    );
  }
}

// ─── Flow B: sendOtp → verifyOtpOnly → register ───────────────────────────────

class _FlowBTabBody extends StatefulWidget {
  const _FlowBTabBody();

  @override
  State<_FlowBTabBody> createState() => _FlowBTabBodyState();
}

class _FlowBTabBodyState extends State<_FlowBTabBody> {
  final _emailCtrl = TextEditingController(text: 'newuser@example.com');
  final _nameCtrl = TextEditingController(text: 'Jane Doe');
  final _passwordCtrl = TextEditingController(text: 'password123');

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlowBCubit, FlowBState>(
      listenWhen: (prev, curr) =>
          curr.snack != null && !identical(curr.snack, prev.snack),
      listener: (ctx, state) => dispatchSnack(ctx, state.snack!),
      builder: (ctx, state) => ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _InfoCard(
            'Flow B: sendOtp() → verifyOtpOnly() → register()',
            'OTP-first signup. Verify email ownership before the user fills the form.',
          ),
          const SizedBox(height: 12),
          _StepIndicator(
            current: state.step,
            labels: const ['Send OTP', 'Verify', 'Register'],
          ),
          const SizedBox(height: 24),
          if (state.step == 0) ...[
            AppTextField(
              controller: _emailCtrl,
              label: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Send OTP',
              isLoading: state.loading,
              onPressed: () =>
                  ctx.read<FlowBCubit>().sendOtp(_emailCtrl.text.trim()),
            ),
          ] else if (state.step == 1) ...[
            Text(
              'Enter the 6-digit OTP sent to ${state.email}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Center(
              child: OtpField(
                length: 6,
                autoFocus: false,
                onCompleted: (otp) =>
                    ctx.read<FlowBCubit>().updateOtp(otp),
                onChanged: (v) => ctx.read<FlowBCubit>().updateOtp(v),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Verify OTP',
              isLoading: state.loading,
              onPressed: state.currentOtp.length == 6
                  ? () => ctx.read<FlowBCubit>().verifyOtpOnly()
                  : null,
            ),
          ] else ...[
            AppTextField(
              controller: _nameCtrl,
              label: 'Full name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 12),
            PasswordField(controller: _passwordCtrl),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Complete Registration',
              isLoading: state.loading,
              onPressed: () => ctx
                  .read<FlowBCubit>()
                  .register(_nameCtrl.text.trim(), _passwordCtrl.text),
            ),
          ],
          if (state.statusText != null) ...[
            const SizedBox(height: 24),
            _StatusCard(state.statusText!),
          ],
        ],
      ),
    );
  }
}

// ─── Shared helpers ───────────────────────────────────────────────────────────

class _StatusCard extends StatelessWidget {
  const _StatusCard(this.message);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(message, style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(this.title, this.body);
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(body, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.current, required this.labels});
  final int current;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final surface = Theme.of(context).colorScheme.surfaceContainerHighest;

    return Row(
      children: List.generate(labels.length, (i) {
        final active = i == current;
        final done = i < current;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: done || active ? primary : surface,
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: active ? Colors.white : null,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                labels[i],
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: active ? FontWeight.bold : null,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }),
    );
  }
}
