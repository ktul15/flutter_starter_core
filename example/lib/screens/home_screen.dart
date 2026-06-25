import 'package:flutter/material.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import 'auth_screen.dart';
import 'pagination_screen.dart';
import 'storage_screen.dart';
import 'validation_screen.dart';
import 'widgets_screen.dart';

/// Entry point — grid of all active modules.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.prefs,
    required this.tokenStore,
    required this.client,
    required this.auth,
    required this.envConfigs,
  });

  final LocalPreferences prefs;
  final TokenStore tokenStore;
  final ApiClient client;
  final AuthService auth;
  final EnvConfigs envConfigs;

  @override
  Widget build(BuildContext context) {
    final modules = [
      _Module(
        'Auth',
        'Login · Register · OTP flows A & B',
        Icons.lock_outline,
        AuthScreen(auth: auth, tokenStore: tokenStore),
      ),
      _Module(
        'Storage',
        'TokenStore · LocalPrefs · EnvConfig',
        Icons.storage_outlined,
        StorageScreen(
          prefs: prefs,
          tokenStore: tokenStore,
          envConfigs: envConfigs,
        ),
      ),
      _Module(
        'Widgets',
        'Buttons · Inputs · Loaders · States',
        Icons.widgets_outlined,
        const WidgetsScreen(),
      ),
      _Module(
        'Validation',
        'All Validators rules + compose()',
        Icons.check_circle_outline,
        const ValidationScreen(),
      ),
      _Module(
        'Pagination',
        'PaginationState<T> · infinite scroll',
        Icons.list_alt_outlined,
        const PaginationScreen(),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('flutter_starter_core')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.15,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: modules.length,
        itemBuilder: (context, i) {
          final m = modules[i];
          return Card(
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute(builder: (_) => m.screen),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(m.icon, size: 28),
                    const SizedBox(height: 8),
                    Text(
                      m.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Expanded(
                      child: Text(
                        m.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Module {
  const _Module(this.title, this.subtitle, this.icon, this.screen);
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget screen;
}
