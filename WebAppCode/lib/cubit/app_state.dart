part of 'app_cubit.dart';

class AppState extends Equatable {
  final SystemResourceState systemResourceState;

  const AppState(this.systemResourceState);

  const AppState.initial({this.systemResourceState = const SystemResourceState.initial()});

  @override
  List<Object> get props => [systemResourceState];

  AppState copyWith({SystemResourceState? systemResourceState}) {
    return AppState(
      systemResourceState ?? this.systemResourceState,
    );
  }
}
