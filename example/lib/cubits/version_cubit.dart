import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class VersionState extends Equatable {
  const VersionState({this.checking = false, this.result});

  final bool checking;
  final ApiResult<AppVersionInfo>? result;

  @override
  List<Object?> get props => [checking, result];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Demonstrates [AppVersionChecker.check] and the [VersionStatus] enum.
class VersionCubit extends Cubit<VersionState> {
  VersionCubit(this._client) : super(const VersionState());

  final ApiClient _client;

  Future<void> check() async {
    emit(const VersionState(checking: true));
    final checker = AppVersionChecker(
      client: _client,
      endpoint: '/app/version',
    );
    final result = await checker.check();
    emit(VersionState(result: result));
  }
}
