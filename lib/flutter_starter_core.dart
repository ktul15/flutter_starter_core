/// flutter_starter_core — reusable Flutter infrastructure.
///
/// Public API barrel. Import this; everything under `src/` is private.
///
/// **Dio types:** this barrel does NOT re-export Dio. Add `dio` to your own
/// `pubspec.yaml` if you need to reference `FormData`, `MultipartFile`,
/// `Options`, `CancelToken`, `DioException`, or `Interceptor` by name.
/// Types returned by package methods (e.g. `ApiClient.dio`) are usable via
/// type inference without an explicit Dio import.
library;

// Module 1 — Network Core
export 'src/network/api_client.dart';
export 'src/network/api_exception.dart';
export 'src/network/api_result.dart';
export 'src/network/request_runner.dart';
export 'src/network/interceptors/auth_interceptor.dart';
export 'src/network/interceptors/error_interceptor.dart';
export 'src/network/interceptors/log_interceptor.dart';
export 'src/network/interceptors/retry_interceptor.dart';

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

// Module 4 — Common Widgets
export 'src/widgets/buttons/primary_button.dart';
export 'src/widgets/inputs/app_text_field.dart';
export 'src/widgets/inputs/password_field.dart';
export 'src/widgets/loaders/app_loader.dart';
export 'src/widgets/loaders/skeleton_box.dart';
export 'src/widgets/states/empty_state.dart';
export 'src/widgets/states/error_state_view.dart';

// Module 5 — Validation + Utils
export 'src/validation/validators.dart';
export 'src/utils/pagination.dart';

// Module 6 — Preferences
export 'src/preferences/app_preferences.dart';
export 'src/preferences/local_preferences.dart';
