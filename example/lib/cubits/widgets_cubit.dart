import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WidgetsState extends Equatable {
  const WidgetsState({this.isButtonLoading = false});

  final bool isButtonLoading;

  @override
  List<Object?> get props => [isButtonLoading];
}

class WidgetsCubit extends Cubit<WidgetsState> {
  WidgetsCubit() : super(const WidgetsState());

  Future<void> simulateLoad() async {
    emit(const WidgetsState(isButtonLoading: true));
    await Future<void>.delayed(const Duration(seconds: 2));
    emit(const WidgetsState());
  }
}
