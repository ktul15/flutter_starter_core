import 'package:flutter/material.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

import 'analytics_screen.dart';
import 'auth_screen.dart';
import 'connectivity_screen.dart';
import 'localization_screen.dart';
import 'media_screen.dart';
import 'messenger_screen.dart';
import 'pagination_screen.dart';
import 'permissions_screen.dart';
import 'push_screen.dart';
import 'route_guard_screen.dart';
import 'storage_screen.dart';
import 'theme_screen.dart';
import 'utils_screen.dart';
import 'validation_screen.dart';
import 'version_screen.dart';
import 'widgets_screen.dart';

/// Entry point screen — grid of all 16 modules.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.prefs,
    required this.themeController,
    required this.tokenStore,
    required this.client,
    required this.auth,
    required this.messenger,
    required this.envConfigs,
  });

  final LocalPreferences prefs;
  final PersistentThemeModeController themeController;
  final TokenStore tokenStore;
  final ApiClient client;
  final AuthService auth;
  final AppMessenger messenger;
  final EnvConfigs envConfigs;

  @override
  Widget build(BuildContext context) {
    final modules = [
      _Module(
        'Auth',
        'Login · Register · OTP flows A & B',
        Icons.lock_outline,
        AuthScreen(auth: auth, tokenStore: tokenStore, messenger: messenger),
      ),
      _Module(
        'Connectivity',
        'Live network status stream',
        Icons.wifi_outlined,
        const ConnectivityScreen(),
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
        'Theme',
        'Persistent light / dark / system',
        Icons.palette_outlined,
        ThemeScreen(controller: themeController),
      ),
      _Module(
        'Localization',
        'LocalizationConfig · resolve()',
        Icons.language_outlined,
        const LocalizationScreen(),
      ),
      _Module(
        'Widgets',
        'Buttons · Inputs · Loaders · States · OTP · Image',
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
      _Module(
        'Utils',
        'Debouncer · DateFormatter · Haptic',
        Icons.build_circle_outlined,
        const UtilsScreen(),
      ),
      _Module(
        'Permissions',
        'Check · Request · Open settings',
        Icons.security_outlined,
        const PermissionsScreen(),
      ),
      _Module(
        'Media',
        'Image · Images · Video · File picker',
        Icons.photo_outlined,
        const MediaScreen(),
      ),
      _Module(
        'Analytics',
        'Events · User · Screen · CrashReporter',
        Icons.analytics_outlined,
        const AnalyticsScreen(),
      ),
      _Module(
        'Messenger',
        'Success · Error · Info · Warning',
        Icons.notifications_outlined,
        MessengerScreen(messenger: messenger),
      ),
      _Module(
        'Version',
        'AppVersionChecker · VersionStatus',
        Icons.system_update_outlined,
        VersionScreen(client: client),
      ),
      _Module(
        'Push',
        'PushService interface · FCM wiring',
        Icons.notifications_active_outlined,
        const PushScreen(),
      ),
      _Module(
        'Route Guard',
        'GuardDecision · evaluate() interactive',
        Icons.route_outlined,
        const RouteGuardScreen(),
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
