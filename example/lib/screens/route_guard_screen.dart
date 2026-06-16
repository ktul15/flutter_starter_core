import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import '../cubits/route_guard_cubit.dart';

/// Interactive demo of [RouteGuard.evaluate] — toggle auth state and route
/// flags to see which [GuardDecision] the guard returns.
class RouteGuardScreen extends StatelessWidget {
  const RouteGuardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RouteGuardCubit(),
      child: const _RouteGuardBody(),
    );
  }
}

class _RouteGuardBody extends StatelessWidget {
  const _RouteGuardBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RouteGuardCubit, RouteGuardState>(
      builder: (ctx, state) {
        final decision = state.guardResult;
        final allowed = decision?.isAllowed ?? false;
        final cs = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(title: const Text('Route Guard')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'RouteGuard.evaluate() is framework-agnostic — wire the result '
                  'into go_router\'s redirect, auto_route\'s guard, or Navigator '
                  'manually. Only the decision logic lives in the package.',
                  style: TextStyle(fontSize: 12),
                ),
              ),

              const Divider(height: 32),

              Text('Guard config', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 4),
              _CodeLine('signInLocation', "'/login'"),
              _CodeLine('initialLocation', "'/home'"),

              const Divider(height: 32),

              Text('Route inputs', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),

              SwitchListTile(
                title: const Text('isAuthenticated'),
                subtitle: const Text('User has a valid session'),
                value: state.isAuthenticated,
                onChanged: (v) => ctx.read<RouteGuardCubit>().setAuthenticated(v),
              ),
              SwitchListTile(
                title: const Text('requiresAuth'),
                subtitle: const Text('Route needs a logged-in user'),
                value: state.requiresAuth,
                onChanged: (v) => ctx.read<RouteGuardCubit>().setRequiresAuth(v),
              ),
              SwitchListTile(
                title: const Text('isAuthRoute'),
                subtitle: const Text('Route is login / register screen'),
                value: state.isAuthRoute,
                onChanged: (v) => ctx.read<RouteGuardCubit>().setAuthRoute(v),
              ),

              const Divider(height: 32),

              Text('Decision', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),

              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: allowed ? cs.tertiaryContainer : cs.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          allowed ? Icons.check_circle : Icons.block,
                          color: allowed ? cs.tertiary : cs.error,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          allowed ? 'GuardAllow' : 'GuardRedirect',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: allowed
                                    ? cs.onTertiaryContainer
                                    : cs.onErrorContainer,
                                fontFamily: 'monospace',
                              ),
                        ),
                      ],
                    ),
                    if (decision != null && !allowed) ...[
                      const SizedBox(height: 8),
                      Text(
                        'redirectTo: "${decision.redirectTo}"',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontFamily: 'monospace',
                              color: cs.onErrorContainer,
                            ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                'Logic summary',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _LogicRow(
                'requiresAuth && !isAuthenticated',
                state.requiresAuth && !state.isAuthenticated,
                'GuardRedirect(signInLocation)',
              ),
              _LogicRow(
                'isAuthRoute && isAuthenticated',
                state.isAuthRoute && state.isAuthenticated,
                'GuardRedirect(initialLocation)',
              ),
              _LogicRow(
                'otherwise',
                !(state.requiresAuth && !state.isAuthenticated) &&
                    !(state.isAuthRoute && state.isAuthenticated),
                'GuardAllow',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CodeLine extends StatelessWidget {
  const _CodeLine(this.key_, this.value);
  final String key_;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        '$key_: $value',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontFamily: 'monospace'),
      ),
    );
  }
}

class _LogicRow extends StatelessWidget {
  const _LogicRow(this.condition, this.matches, this.result);
  final String condition;
  final bool matches;
  final String result;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            matches ? Icons.radio_button_checked : Icons.radio_button_unchecked,
            size: 16,
            color: matches
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$condition → $result',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: matches ? FontWeight.w600 : null,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
