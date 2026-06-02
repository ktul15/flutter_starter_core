import 'package:freezed_annotation/freezed_annotation.dart';

import 'user.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

/// Token bundle (and optional [user]) returned by auth endpoints.
///
/// **Default shape — [PER-PROJECT].** Adjust the `@JsonKey` mappings to match
/// the backend's token field names.
@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    @JsonKey(name: 'access_token') required String accessToken,
    @JsonKey(name: 'refresh_token') String? refreshToken,
    User? user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
