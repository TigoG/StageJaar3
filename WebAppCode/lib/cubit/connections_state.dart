part of 'package:sen_gs_1_web/cubit/connections_cubit.dart';

class ConnectionsState extends Equatable {
  /// Map of device connection IDs to their respective device managers
  final EquatableMap<GenericConnectionInfo> connectionInfoMap;
  final UniqueKey stateKey = UniqueKey();

  ConnectionsState(Map<String, GenericConnectionInfo> connectionInfoMap)
      : connectionInfoMap = EquatableMap(connectionInfoMap);

  ConnectionsState.initial() : connectionInfoMap = EquatableMap(const {});

  ConnectionsState copyWith(
      {required Map<String, GenericConnectionInfo> newConnectionInfoMap}) {
    return ConnectionsState(newConnectionInfoMap);
  }

  @override
  List<Object> get props => [connectionInfoMap.hashCode, stateKey];
}

/// Utility class allowing a map of device managers to efficiently be compared
/// by value.
class EquatableMap<T> extends Equatable {
  final Map<String, T> _equatableMap;

  EquatableMap(Map<String, T> map) : _equatableMap = Map.unmodifiable(map);

  Map<String, T> get map => _equatableMap;

  // Implement a deep comparison of map contents.
  @override
  List<Object?> get props => [_equatableMap];
}