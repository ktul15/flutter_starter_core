import 'package:mobilions_core/mobilions_core.dart';

/// In-memory [TokenStore] for tests. No platform channels.
class FakeTokenStore implements TokenStore {
  FakeTokenStore({String? accessToken, String? refreshToken})
      : _access = accessToken,
        _refresh = refreshToken;

  String? _access;
  String? _refresh;

  int writeCount = 0;
  int clearCount = 0;

  @override
  Future<String?> readAccessToken() async => _access;

  @override
  Future<String?> readRefreshToken() async => _refresh;

  @override
  Future<void> writeTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    writeCount++;
    _access = accessToken;
    if (refreshToken != null) {
      _refresh = refreshToken.isEmpty ? null : refreshToken;
    }
  }

  @override
  Future<void> clear() async {
    clearCount++;
    _access = null;
    _refresh = null;
  }

  @override
  Future<bool> get hasAccessToken async => _access?.isNotEmpty ?? false;
}
