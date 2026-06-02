import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_request.freezed.dart';
part 'register_request.g.dart';

/// Registration payload.
///
/// **Default shape — [PER-PROJECT].** Add/remove fields and adjust JSON keys to
/// match the backend's register endpoint.
@freezed
abstract class RegisterRequest with _$RegisterRequest {
  const factory RegisterRequest({
    required String email,
    required String password,
    String? name,
    @JsonKey(name: 'password_confirmation') String? passwordConfirmation,
  }) = _RegisterRequest;

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
}
