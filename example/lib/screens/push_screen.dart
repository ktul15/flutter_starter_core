import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/push_cubit.dart';

/// Demonstrates the [PushService] interface and how to wire a concrete impl.
class PushScreen extends StatelessWidget {
  const PushScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PushCubit(),
      child: const _PushBody(),
    );
  }
}

class _PushBody extends StatelessWidget {
  const _PushBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PushCubit, PushState>(
      builder: (ctx, state) => Scaffold(
        appBar: AppBar(title: const Text('Push Notifications')),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PushService is an interface — no FCM SDK is bundled. '
                      'Implement it in your project (e.g. using firebase_messaging) '
                      'and inject your implementation. '
                      'This demo uses _DemoPushService which returns stub values.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'class MyFcmPushService implements PushService {\n'
                      '  final _messaging = FirebaseMessaging.instance;\n\n'
                      '  @override\n'
                      '  Future<String?> getToken() => _messaging.getToken();\n\n'
                      '  @override\n'
                      '  Stream<PushMessage> get onMessage =>\n'
                      '    FirebaseMessaging.onMessage.map(_toMessage);\n'
                      '  // ... implement remaining methods\n'
                      '}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilledButton(
                        onPressed: () =>
                            ctx.read<PushCubit>().requestPermission(),
                        child: const Text('requestPermission'),
                      ),
                      FilledButton(
                        onPressed: () =>
                            ctx.read<PushCubit>().getToken(),
                        child: const Text('getToken'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            ctx.read<PushCubit>().subscribeToTopic(),
                        child: const Text('subscribe topic'),
                      ),
                      OutlinedButton(
                        onPressed: () => ctx
                            .read<PushCubit>()
                            .unsubscribeFromTopic(),
                        child: const Text('unsubscribe topic'),
                      ),
                      OutlinedButton(
                        onPressed: () =>
                            ctx.read<PushCubit>().getInitialMessage(),
                        child: const Text('getInitialMessage'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),
            Container(
              height: 160,
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Call log',
                        style:
                            Theme.of(context).textTheme.labelMedium,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () =>
                            ctx.read<PushCubit>().clearLog(),
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
                                    ?.copyWith(
                                        fontFamily: 'monospace'),
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
