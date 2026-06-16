import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class StorageState extends Equatable {
  const StorageState({
    this.accessToken,
    this.refreshToken,
    this.prefValue,
  });

  final String? accessToken;
  final String? refreshToken;

  /// Result of the last [LocalPreferences.getString] call.
  final String? prefValue;

  @override
  List<Object?> get props => [accessToken, refreshToken, prefValue];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Drives the Storage screen: [TokenStore] read/write/clear + [LocalPreferences].
class StorageCubit extends Cubit<StorageState> {
  StorageCubit(this._tokenStore, this._prefs) : super(const StorageState()) {
    scheduleMicrotask(readTokens);
  }

  final TokenStore _tokenStore;
  final LocalPreferences _prefs;

  Future<void> readTokens() async {
    final a = await _tokenStore.readAccessToken();
    final r = await _tokenStore.readRefreshToken();
    emit(StorageState(
      accessToken: a,
      refreshToken: r,
      prefValue: state.prefValue,
    ));
  }

  Future<void> writeTokens(String access, String refresh) async {
    await _tokenStore.writeTokens(
      accessToken: access,
      refreshToken: refresh,
    );
    await readTokens();
  }

  Future<void> clearTokens() async {
    await _tokenStore.clear();
    await readTokens();
  }

  Future<void> readPref(String key) async {
    final v = await _prefs.getString(key);
    emit(StorageState(
      accessToken: state.accessToken,
      refreshToken: state.refreshToken,
      prefValue: v ?? '(null)',
    ));
  }

  Future<void> writePref(String key, String value) async {
    await _prefs.setString(key, value);
    await readPref(key);
  }

  Future<void> deletePref(String key) async {
    await _prefs.remove(key);
    emit(StorageState(
      accessToken: state.accessToken,
      refreshToken: state.refreshToken,
    ));
  }
}
