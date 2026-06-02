import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

/// Authenticated user.
///
/// **Default shape — [PER-PROJECT].** Field names and JSON keys here are a
/// starting point; consumers are expected to fork/replace this model (and the
/// `@JsonKey` mappings) to match their backend.
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? name,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'email_verified') @Default(false) bool emailVerified,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
