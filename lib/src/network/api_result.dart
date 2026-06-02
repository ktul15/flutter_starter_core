import 'api_exception.dart';

/// Result of a network call: either [Success] with parsed data or [Failure]
/// with an [ApiException].
///
/// A native Dart 3 sealed type — exhaustive `switch`/pattern matching is the
/// intended consumption style:
///
/// ```dart
/// switch (result) {
///   case Success(:final data): show(data);
///   case Failure(:final error): showError(error.message);
/// }
/// ```
///
/// Hand-written rather than freezed: freezed adds little for a generic union
/// with no JSON, and native sealed classes give cleaner exhaustive matching.
sealed class ApiResult<T> {
  const ApiResult();

  /// `true` when this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// `true` when this is a [Failure].
  bool get isFailure => this is Failure<T>;

  /// The data if [Success], otherwise `null`.
  T? get dataOrNull => switch (this) {
        Success(:final data) => data,
        Failure() => null,
      };

  /// The error if [Failure], otherwise `null`.
  ApiException? get errorOrNull => switch (this) {
        Success() => null,
        Failure(:final error) => error,
      };

  /// Folds both branches into a single value.
  R when<R>({
    required R Function(T data) success,
    required R Function(ApiException error) failure,
  }) =>
      switch (this) {
        Success(:final data) => success(data),
        Failure(:final error) => failure(error),
      };

  /// Maps a [Success] payload while passing [Failure] through untouched.
  ApiResult<R> map<R>(R Function(T data) transform) => switch (this) {
        Success(:final data) => Success(transform(data)),
        Failure(:final error) => Failure(error),
      };
}

/// Successful result carrying parsed [data].
final class Success<T> extends ApiResult<T> {
  const Success(this.data);

  final T data;
}

/// Failed result carrying a normalized [error].
final class Failure<T> extends ApiResult<T> {
  const Failure(this.error);

  final ApiException error;
}
