import 'dart:async';
import 'package:sen_gs_1_ca_connector_plugin/connector_plugin_platform_interface.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/system_resource_state.dart';

class SystemResourceController {
  static final SystemResourceController _systemResourceController =
      SystemResourceController._internal();

  factory SystemResourceController() {
    return _systemResourceController;
  }

  SystemResourceController._internal();

  Future<void> initialize() async {
    await ConnectorPluginPlatform.instance.initialize();
  }

  Future<void> signIn(String email, String password) async {
    await ConnectorPluginPlatform.instance.signIn(email, password);
  }

  Future<void> signOut() async {
    await ConnectorPluginPlatform.instance.signOut();
  }

  Future<void> signUp(
      String email,
      String password,
      String firstName,
      String lastName,
      String dateOfBirth,
      String phoneNumber,
      String photo) async {
    await ConnectorPluginPlatform.instance.signUp(
        email, password, firstName, lastName, dateOfBirth, phoneNumber, photo);
  }

  Future<void> forgotPassword(String email) async {
    await ConnectorPluginPlatform.instance.forgotPassword(email);
  }

  Future<void> confirmPasswordReset(
      String email, String verificationCode, String password) async {
    await ConnectorPluginPlatform.instance
        .confirmPasswordReset(email, verificationCode, password);
  }

  Future<void> confirmAccount(String email, String verificationCode) async {
    await ConnectorPluginPlatform.instance
        .confirmAccount(email, verificationCode);
  }

  Future<void> resendConfirmationCode(String email) async {
    await ConnectorPluginPlatform.instance.resendConfirmationCode(email);
  }

  Future<void> cancelForgotPassword() async {
    await ConnectorPluginPlatform.instance.cancelForgotPassword();
  }

  Future<Stream<SystemResourceState>> observeConnectorState() async {
    final stream =
        ConnectorPluginPlatform.instance.getSystemResourceStateStream();

    final StreamController<SystemResourceState> streamController =
        StreamController.broadcast();

    streamController
        .addStream(stream)
        .then((value) => streamController.close());

    return streamController.stream;
  }
}
