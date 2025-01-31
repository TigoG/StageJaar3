import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:sen_gs_1_ca_connector_plugin/method_channel_connector_plugin.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/data/data_point.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/data/data_point_set.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connection_event.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connector_device.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/idi/idi_connector_device_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/system_resource_state.dart';

abstract class ConnectorPluginPlatform extends PlatformInterface {
  // ==== PlatformInterface Requirements =====
  /// Constructs a ConnectorPluginPlatform.
  ConnectorPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static ConnectorPluginPlatform _instance = MethodChannelConnectorPlugin();

  /// The default instance of [WebTestPlatform] to use.
  static ConnectorPluginPlatform get instance => _instance;

  /// Setter to override the current instance
  static set instance(ConnectorPluginPlatform instance) {
    // Verifies the new instance is valid using the token
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  // ==== Platform Streams ====

  Stream<SystemResourceState> getSystemResourceStateStream();

  Stream<GenericConnectionEvent> getConnectionEventStream();

  // ==== Interfacing Methods ====

  // = General Methods =
  Future<void> initialize();

  Future<void> signIn(String email, String password);

  Future<void> signOut();

  Future<void> signUp(String email, String password, String firstName,
      String lastName, String dateOfBirth, String phoneNumber, String photo);

  Future<void> forgotPassword(String email);

  Future<void> confirmPasswordReset(
      String email, String verificationCode, String password);

  Future<void> confirmAccount(String email, String verificationCode);

  Future<void> resendConfirmationCode(String email);

  Future<void> cancelForgotPassword();

  // = Device-related Methods =
  Future<void> connectToDevice(GenericConnectorDevice device);

  Future<void> disconnectDevice(GenericConnectorDevice device);

  Future<void> startCgmSession(
      GenericConnectorDevice device, String sessionId, bool useDebugParams);

  Future<void> setDebugParameters(
      GenericConnectorDevice device, IdiDebugParameters params);

  Future<void> setProductionParameters(GenericConnectorDevice device, data);

  Future<void> readProductionParameters(GenericConnectorDevice device);

  Future<void> stopCgmSession(GenericConnectorDevice device);

  Future<void> addCalibration(
      GenericConnectorDevice device, DataPoint value, bool calibrateAll);

  // = Cloud-related Methods
  Future<Map<String, DataPointSet>> retrieveSession(String? sessionId);

  Future<void> addDataPoint(DataPoint point);

  Future<void> startScanning(String connectionId);

  Future<void> stopScanning();

  Future<void> startNfcPairing();

  Future<void> stopNfcPairing();
}
