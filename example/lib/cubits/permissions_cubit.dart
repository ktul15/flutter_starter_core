import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_starter_core/flutter_starter_core.dart';

// ── State ──────────────────────────────────────────────────────────────────────

class PermissionsState extends Equatable {
  const PermissionsState({this.statuses = const {}, this.loading = false});

  final Map<AppPermission, PermissionStatus> statuses;
  final bool loading;

  @override
  List<Object?> get props => [statuses, loading];
}

// ── Cubit ──────────────────────────────────────────────────────────────────────

/// Demonstrates [AppPermissions] — check, request, and open settings.
class PermissionsCubit extends Cubit<PermissionsState> {
  PermissionsCubit() : super(const PermissionsState());

  final _handler = AppPermissions();

  Future<void> check(AppPermission permission) async {
    final status = await _handler.check(permission);
    emit(PermissionsState(
      statuses: {...state.statuses, permission: status},
      loading: state.loading,
    ));
  }

  Future<void> request(AppPermission permission) async {
    emit(PermissionsState(statuses: state.statuses, loading: true));
    final status = await _handler.request(permission);
    emit(PermissionsState(
      statuses: {...state.statuses, permission: status},
    ));
  }

  Future<void> checkAll() async {
    emit(PermissionsState(statuses: state.statuses, loading: true));
    final updated = {...state.statuses};
    for (final p in AppPermission.values) {
      updated[p] = await _handler.check(p);
    }
    emit(PermissionsState(statuses: updated));
  }

  Future<void> openSettings() => _handler.openSettings();
}
