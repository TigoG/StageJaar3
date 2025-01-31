import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sen_gs_1_ca_connector_plugin/connector_plugin_platform_interface.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/data/data_point.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/data/data_point_set.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connection_event.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connector_device.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connector_device_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/idi/idi_connector_device_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/system_resource_state.dart';

class MethodChannelConnectorPlugin extends ConnectorPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('connectorPlugin');

  /// ==== Streams ====

  Stream<SystemResourceState>? _systemResourceStateStream;
  Stream<GenericConnectionEvent>? _connectionEventStream;

  @override
  Stream<SystemResourceState> getSystemResourceStateStream() {
    _systemResourceStateStream ??= const EventChannel(
            "connectorPlugin/systemResourceStateEvents")
        .receiveBroadcastStream()
        .handleError((error) => throw error)
        .map((rawJson) => SystemResourceState.fromJson(jsonDecode(rawJson)));
    return _systemResourceStateStream!;
  }

  @override
  Stream<GenericConnectionEvent> getConnectionEventStream() {
    _connectionEventStream ??=
        const EventChannel("connectorPlugin/deviceEvents")
            .receiveBroadcastStream()
            .map((rawMap) => GenericConnectionEvent.fromJson(
                jsonDecode(rawMap)))
            .handleError((error) {
      throw error;
    });
    return _connectionEventStream!;
  }

  /// ==== Platform Interfacing Methods ====

  @override
  Future<void> initialize() async {
    // TODO JB: Check if we need something like this
    // await _isPluginReady; // Wait for the native plugin to be ready
    await methodChannel.invokeMethod("initialize");
  }

  @override
  Future<void> signIn(String email, String password) async {
    await methodChannel
        .invokeMethod("signIn", {"email": email, "password": password});
  }

  @override
  Future<void> signOut() async {
    await methodChannel.invokeMethod("signOut");
  }

  @override
  Future<void> signUp(
      String email,
      String password,
      String firstName,
      String lastName,
      String dateOfBirth,
      String phoneNumber,
      String photo) async {
    await methodChannel.invokeMethod("signUp", {
      "email": email,
      "password": password,
      "firstName": firstName,
      "lastName": lastName,
      "dateOfBirth": dateOfBirth,
      "phoneNumber": phoneNumber,
      "photo": photo
    });
  }

  @override
  Future<void> forgotPassword(String email) async {
    await methodChannel.invokeMethod("forgotPassword", {"email": email});
  }

  @override
  Future<void> confirmPasswordReset(
    String email,
    String verificationCode,
    String password,
  ) async {
    await methodChannel.invokeMethod("confirmPasswordReset", {
      "email": email,
      "verificationCode": verificationCode,
      "password": password
    });
  }

  @override
  Future<void> confirmAccount(String email, String verificationCode) async {
    await methodChannel.invokeMethod("confirmAccount",
        {"email": email, "verificationCode": verificationCode});
  }

  @override
  Future<void> resendConfirmationCode(String email) async {
    await methodChannel
        .invokeMethod("resendConfirmationCode", {"email": email});
  }

  @override
  Future<void> cancelForgotPassword() async {
    await methodChannel.invokeMethod("cancelForgotPassword");
  }

  @override
  Future<void> connectToDevice(GenericConnectorDevice device) async {
    await methodChannel
        .invokeMethod("connectToDevice", {"device": device.toJson()});
  }

  @override
  Future<void> addCalibration(
      GenericConnectorDevice<GenericConnectorDeviceState> device,
      DataPoint value,
      bool calibrateAll) async {
    await methodChannel.invokeMethod("addCalibration", {
      "address": device.address,
      "point": jsonEncode(value.toMap()),
      "calibrateAll": calibrateAll,
    });
  }

  @override
  Future<void> addDataPoint(DataPoint point) {
    // TODO: implement addDataPoint
    throw UnimplementedError();
  }

  @override
  Future<void> disconnectDevice(
      GenericConnectorDevice<GenericConnectorDeviceState> device) async {
    await methodChannel
        .invokeMethod("disconnectDevice", {"address": device.address});
  }

  @override
  Future<void> readProductionParameters(
      GenericConnectorDevice<GenericConnectorDeviceState> device) async {
    return await methodChannel.invokeMethod("readProdParameters", {
      "address": device.address,
    });
  }

  @override
  Future<Map<String, DataPointSet>> retrieveSession(String? sessionId) async {
    final rawSession = await methodChannel
        .invokeMethod("getMeasurementSession", {"sessionId": sessionId});
    final decoded = (jsonDecode(rawSession) as Map<String, dynamic>);
    return decoded.map((key, value) {
      if (value is String) {
        return MapEntry(key, DataPointSet.fromJson(jsonDecode(value)));
      } else {
        return MapEntry(key, DataPointSet.fromJson(value));
      }
    });
  }

  @override
  Future<void> setDebugParameters(
      GenericConnectorDevice<GenericConnectorDeviceState> device,
      IdiDebugParameters params) async {
    return await methodChannel.invokeMethod("setDebugParameters", {
      "address": device.address,
      "params": params.toJson(),
    });
  }

  @override
  Future<void> setProductionParameters(
      GenericConnectorDevice<GenericConnectorDeviceState> device, data) async {
    return await methodChannel.invokeMethod("setProdParameters", {
      "address": device.address,
      "params": data.toJson(),
    });
  }

  @override
  Future<void> startCgmSession(
      GenericConnectorDevice<GenericConnectorDeviceState> device,
      String sessionId,
      bool useDebugParams) async {
    return await methodChannel.invokeMethod("startCgmSession", {
      "device": device.toJson(),
      "sessionId": sessionId,
      "writeDefaultSessionParameters": !useDebugParams
    });
  }

  @override
  Future<void> stopCgmSession(
      GenericConnectorDevice<GenericConnectorDeviceState> device) async {
    return await methodChannel.invokeMethod("stopCgmSession", {
      "device": device.toJson(),
    });
  }

  @override
  Future<void> startScanning(String connectionId) async {
    return await methodChannel
        .invokeMethod("startScanning", {"connectionId": connectionId});
  }

  @override
  Future<void> stopScanning() async {
    return await methodChannel.invokeMethod("stopScanning");
  }

  @override
  Future<void> startNfcPairing() async {
    await methodChannel.invokeMethod("startNfcPairing");
  }

  @override
  Future<void> stopNfcPairing() async {
    await methodChannel.invokeMethod("stopNfcPairing");
  }
}
