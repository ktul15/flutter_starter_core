/// flutter_starter_core — reusable Flutter infrastructure.
///
/// Public API barrel. Import this; everything under `src/` is private.
library;

// Module 1 — Network Core
export 'src/network/api_client.dart';
export 'src/network/api_exception.dart';
export 'src/network/api_result.dart';
export 'src/network/error_mapper.dart' show mapDioException;
export 'src/network/request_runner.dart';
export 'src/network/interceptors/auth_interceptor.dart';
export 'src/network/interceptors/error_interceptor.dart';
export 'src/network/interceptors/log_interceptor.dart';

// Module 2 — Storage + Config
export 'src/storage/token_store.dart';
export 'src/storage/secure_token_store.dart';
export 'src/config/env_config.dart';

// Module 3 — Auth Service
export 'src/auth/auth_service.dart';
export 'src/auth/auth_endpoints.dart';
export 'src/auth/models/user.dart';
export 'src/auth/models/auth_response.dart';
export 'src/auth/models/register_request.dart';

// Module 4 — Social Login (abstraction only; provider impls are per-project)
export 'src/auth/social/social_auth_result.dart';
export 'src/auth/social/social_auth_provider.dart';
export 'src/auth/social/social_auth_exception.dart';

// Module 5 — Connectivity
export 'src/connectivity/connectivity_checker.dart';
export 'package:connectivity_plus/connectivity_plus.dart'
    show Connectivity, ConnectivityResult;

// Module 6 — Theming
export 'src/theme/app_theme.dart';
export 'src/theme/theme_mode_controller.dart';
export 'src/theme/persistent_theme_controller.dart';

// Module 7 — Localization
export 'src/localization/localization_setup.dart';
export 'package:flutter_localizations/flutter_localizations.dart'
    show
        GlobalCupertinoLocalizations,
        GlobalMaterialLocalizations,
        GlobalWidgetsLocalizations;

// Module 8 — Common Widgets
export 'src/widgets/buttons/primary_button.dart';
export 'src/widgets/inputs/app_text_field.dart';
export 'src/widgets/inputs/password_field.dart';
export 'src/widgets/loaders/app_loader.dart';
export 'src/widgets/loaders/skeleton_box.dart';
export 'src/widgets/states/empty_state.dart';
export 'src/widgets/states/error_state_view.dart';

// Module 9 — Validation + Utils
export 'src/validation/validators.dart';
export 'src/utils/pagination.dart';

// Module 10 — Routing Guard
export 'src/routing/route_guard.dart';

// Module 11 — Retry Interceptor
export 'src/network/interceptors/retry_interceptor.dart';

// Module 12 — Utilities
export 'src/utils/debouncer.dart';
export 'src/utils/date_formatter.dart';
export 'src/utils/haptic_service.dart';

// Module 13 — Preferences
export 'src/preferences/app_preferences.dart';
export 'src/preferences/local_preferences.dart';

// Module 14 — Crash Reporting
export 'src/crash/crash_reporter.dart';

// Module 15 — Analytics
export 'src/analytics/analytics_event.dart';
export 'src/analytics/analytics_service.dart';

// Module 16 — Push Notifications
export 'src/push/push_message.dart';
export 'src/push/push_service.dart';

// Module 17 — Permissions
export 'src/permissions/app_permission.dart';
export 'src/permissions/permission_handler.dart';

// Module 18 — Media Picker
export 'src/media/media_file.dart';
export 'src/media/media_picker.dart';
export 'src/network/media_file_upload.dart'; // MediaFileUpload extension (toMultipartFile)

// Module 19 — OTP Widget
export 'src/widgets/inputs/otp_field.dart';

// Module 20 — AppMessenger
export 'src/messenger/app_messenger.dart';

// Module 21 — Network Image
export 'src/widgets/image/app_network_image.dart';

// Module 22 — Version Checker
export 'src/version/version_status.dart';
export 'src/version/version_checker.dart';

// Re-export Dio types consumers need when wiring the client.
export 'package:dio/dio.dart'
    show
        Dio,
        FormData,
        Interceptor,
        MultipartFile,
        Options,
        Response,
        CancelToken,
        DioException;
