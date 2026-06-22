import 'package:flutter/foundation.dart';

/// Contract for error/crash reporting services (Crashlytics, Sentry, etc.).
///
/// Implement this interface in the consuming app and wire it once via
/// [CrashReporterWiring.attach] so all unhandled Flutter and Dart errors are
/// captured automatically.
///
/// **[PER-PROJECT] implementation.** The package intentionally does not bundle
/// a concrete SDK to avoid forcing a specific crash backend on consumers.
abstract interface class CrashReporter {
  /// Records [error] with optional [stack].
  ///
  /// Set [fatal] to `true` for errors that terminate the app.
  Future<void> recordError(
    Object error,
    StackTrace? stack, {
    bool fatal = false,
  });

  /// Records a [FlutterErrorDetails] from [FlutterError.onError].
  Future<void> recordFlutterError(FlutterErrorDetails details);

  /// Associates subsequent errors with [userId] (e.g. after login).
  Future<void> setUser(String userId);

  /// Clears the user association (e.g. after logout).
  Future<void> clearUser();

  /// Attaches a custom key-value pair to subsequent error reports.
  Future<void> setCustomKey(String key, Object value);

  /// Logs a breadcrumb message visible in the crash report.
  Future<void> log(String message);
}

/// Wires a [CrashReporter] to Flutter's global error handlers.
///
/// Call [attach] once in `main()`, after `WidgetsFlutterBinding.ensureInitialized()`.
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   final reporter = MyCrashlytics(); // your per-project impl
///   CrashReporterWiring.attach(reporter);
///   runApp(const MyApp());
/// }
/// ```
abstract final class CrashReporterWiring {
  /// Routes all unhandled Flutter and Dart errors to [reporter].
  ///
  /// **Chains** existing handlers rather than replacing them — calling [attach]
  /// multiple times (or after a test framework installs its own handler) does
  /// not discard earlier error hooks.
  static void attach(CrashReporter reporter) {
    final prevFlutter = FlutterError.onError;
    FlutterError.onError = (details) {
      reporter.recordFlutterError(details);
      prevFlutter?.call(details);
    };

    final prevPlatform = PlatformDispatcher.instance.onError;
    PlatformDispatcher.instance.onError = (error, stack) {
      reporter.recordError(error, stack, fatal: true);
      return prevPlatform?.call(error, stack) ?? true;
    };
  }
}
