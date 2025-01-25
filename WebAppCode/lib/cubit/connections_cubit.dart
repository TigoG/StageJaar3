import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_connector_plugin/connection_manager_controller.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/generic_connection_info.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/idi_connection_info.dart';

part 'package:sen_gs_1_web/cubit/connections_state.dart';

class ConnectionsCubit extends Cubit<ConnectionsState> {
  late final ConnectionManagerController deviceManagerController;
  Map<String, GenericConnectionInfo> previousConnections = {};

  ConnectionsCubit() : super(ConnectionsState.initial()) {
    deviceManagerController = ConnectionManagerController();

    deviceManagerController.deviceConnectionsStream.listen((event) {
      final Map<String, GenericConnectionInfo> connections = {};
      
      // Handling device connections
      event.forEach((key, deviceManager) {
        if (deviceManager is IdiLocalConnectionManager) {
          connections[key] = IdiConnectionInfo(deviceManager);
        } else {
          log("Connected an incompatible device: $key");
        }
      });

      // Cleanup logic for removed connections
      previousConnections.forEach((key, connectionInfo) {
        if (!connections.containsKey(key)) {
          connectionInfo.cleanUp();
        }
      });

      previousConnections = connections;

      emit(state.copyWith(newConnectionInfoMap: connections));
    });
  }

  /// Manually update connections state to reflect user changes
  void refreshConnectionsMap() {
    emit(state.copyWith(newConnectionInfoMap: {}));
  }
}
