import 'package:sen_gs_1_ca_connector_plugin/connector_plugin_platform_interface.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/data/data_point.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/data/data_point_set.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connection_event.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connector_device.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/idi/idi_connector_device_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/system_resource_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/user.dart';
import '../web/web_connector_library.dart'; 
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

class WebConnectorPlugin extends ConnectorPluginPlatform {
  final WebConnectorLibrary _webConnectorLibrary = WebConnectorLibrary();

  static Future<void> registerWith(Registrar registrar) async {
    ConnectorPluginPlatform.instance = WebConnectorPlugin();
    
    registrar.registerMessageHandler();
  }

  @override
  Future<void> initialize() async {
    await _webConnectorLibrary.initialize();
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _webConnectorLibrary.signIn(email, password);
  }

  @override
  Future<void> signOut() async {
    await _webConnectorLibrary.signOut();
  }

  @override
  Future<void> signUp(String email, String password, String firstName,
      String lastName, String dateOfBirth, String phoneNumber, String photo) async {
    await _webConnectorLibrary.signUp(email, password, firstName, lastName, dateOfBirth, phoneNumber, photo);
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _webConnectorLibrary.forgotPassword(email);
  }

  @override
  Future<void> confirmPasswordReset(
      String email, String verificationCode, String password) async {
    await _webConnectorLibrary.confirmPasswordReset(email, verificationCode, password);
  }

  @override
  Future<void> confirmAccount(String email, String verificationCode) async {
    await _webConnectorLibrary.confirmAccount(email, verificationCode);
  }

  @override
  Future<void> resendConfirmationCode(String email) async {
    await _webConnectorLibrary.resendConfirmationCode(email);
  }

  @override
  Future<void> cancelForgotPassword() async {
    await _webConnectorLibrary.cancelForgotPassword();
  }

  @override
  Future<void> connectToDevice(GenericConnectorDevice device) async {
    await _webConnectorLibrary.connectToDevice(device);
  }

  @override
  Future<void> disconnectDevice(GenericConnectorDevice device) async {
    await _webConnectorLibrary.disconnectDevice(device);
  }

  @override
  Future<void> startCgmSession(GenericConnectorDevice device, String sessionId, bool useDebugParams) async {
    await _webConnectorLibrary.startCgmSession(device, sessionId, useDebugParams);
  }

  @override
  Future<void> setDebugParameters(GenericConnectorDevice device, IdiDebugParameters params) async {
    await _webConnectorLibrary.setDebugParameters(device, params);
  }

  @override
  Future<void> setProductionParameters(GenericConnectorDevice device, data) async {
    await _webConnectorLibrary.setProductionParameters(device, data);
  }

  @override
  Future<void> readProductionParameters(GenericConnectorDevice device) async {
    await _webConnectorLibrary.readProductionParameters(device);
  }

  @override
  Future<void> stopCgmSession(GenericConnectorDevice device) async {
    await _webConnectorLibrary.stopCgmSession(device);
  }

  @override
  Future<void> addCalibration(GenericConnectorDevice device, DataPoint value, bool calibrateAll) async {
    await _webConnectorLibrary.addCalibration(device, value, calibrateAll);
  }

  @override
  Future<Map<String, DataPointSet>> retrieveSession(String? sessionId) async {
    final rawSession = await _webConnectorLibrary.retrieveSession(sessionId);
    return rawSession.map((key, value) => MapEntry(key, DataPointSet.fromJson(value)));
  }

  @override
  Future<void> addDataPoint(DataPoint point) async {
    await _webConnectorLibrary.addDataPoint(point);
  }

  @override
  Future<void> startScanning(String connectionId) async {
    await _webConnectorLibrary.startScanning(connectionId);
  }

  @override
  Future<void> stopScanning() async {
    await _webConnectorLibrary.stopScanning();
  }

  @override
  Future<void> startNfcPairing() async {
    await _webConnectorLibrary.startNfcPairing();
  }

  @override
  Future<void> stopNfcPairing() async {
    await _webConnectorLibrary.stopNfcPairing();
  }

  @override
  Stream<SystemResourceState> getSystemResourceStateStream() {
    return _webConnectorLibrary.getSystemResourceStateStream();
  }

  @override
  Stream<GenericConnectionEvent> getConnectionEventStream() {
    return _webConnectorLibrary.getConnectionEventStream();
  }

  Future<User?> initializeAuthenticationState(){
    return _webConnectorLibrary.initializeAuthenticationState();
  }

  Future<User?> fetchUser() async {
    return await _webConnectorLibrary.fetchUser();
  }
}
