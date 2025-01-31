// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/data/data_point.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connection_event.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connector_device.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/generic_connector_device_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/device/idi/idi_connector_device_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/system_resource_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/user.dart';
import 'dart:async';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'amplify_configuration.dart';

class WebConnectorLibrary {
  static Future<void> registerWith(Registrar registrar) async {
    registrar.registerMessageHandler();
  }

  static Future<void> configureAmplify() async {
    final auth = AmplifyAuthCognito();
    final api = AmplifyAPI();

    try {
      await Amplify.addPlugins([auth, api]);
      await Amplify.configure(jsonEncode(amplifyConfig));
    } catch (e) {
      print("Amplify Configuration Error: $e");
    }
  }

  Future<void> initialize() async {
    await configureAmplify();
  }

  /// Sign in a user using AWS Amplify.
  Future<void> signIn(String email, String password) async {
    try {
      final result = await Amplify.Auth.signIn(
        username: email,
        password: password,
      );
      if (result.isSignedIn) {
        print("User signed in successfully.");
      } else {
        print("Sign-in process not completed.");
      }
    } catch (e) {
      print("Error signing in: $e");
    }
  }

  /// Sign out a user using AWS Amplify.
  Future<void> signOut() async {
    try {
      await Amplify.Auth.signOut();
      print("User signed out successfully.");
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  /// Sign up a new user using AWS Amplify.
  Future<void> signUp(
    String email,
    String password,
    String firstName,
    String lastName,
    String dateOfBirth,
    String phoneNumber,
    String photo,
  ) async {
    try {
      final userAttributes = {
        CognitoUserAttributeKey.email: email,
        CognitoUserAttributeKey.givenName: firstName,
        CognitoUserAttributeKey.familyName: lastName,
        CognitoUserAttributeKey.birthdate: dateOfBirth,
        CognitoUserAttributeKey.phoneNumber: phoneNumber,
      };

      final result = await Amplify.Auth.signUp(
        username: email,
        password: password,
        options: SignUpOptions(userAttributes: userAttributes),
      );

      print("Sign-up successful: ${result.isSignUpComplete}");
    } catch (e) {
      print("Error signing up: $e");
    }
  }

  /// Confirm a user's account using a verification code.
  Future<void> confirmAccount(String email, String verificationCode) async {
    try {
      final result = await Amplify.Auth.confirmSignUp(
        username: email,
        confirmationCode: verificationCode,
      );
      if (result.isSignUpComplete) {
        print("Account confirmed successfully.");
      } else {
        print("Account confirmation incomplete.");
      }
    } catch (e) {
      print("Error confirming account: $e");
    }
  }

  /// Resend a confirmation code to a user.
  Future<void> resendConfirmationCode(String email) async {
    try {
      final result = await Amplify.Auth.resendSignUpCode(username: email);
      print("Confirmation code sent: ${result.codeDeliveryDetails}");
    } catch (e) {
      print("Error resending confirmation code: $e");
    }
  }

  /// Reset a user's password.
  Future<void> forgotPassword(String email) async {
    try {
      final result = await Amplify.Auth.resetPassword(username: email);
      print("Password reset initiated: ${result.isPasswordReset}");
    } catch (e) {
      print("Error initiating password reset: $e");
    }
  }

  /// Confirm password reset with a verification code.
  Future<void> confirmPasswordReset(
    String email,
    String verificationCode,
    String password,
  ) async {
    try {
      final result = await Amplify.Auth.confirmResetPassword(
        username: email,
        newPassword: password,
        confirmationCode: verificationCode,
      );
      print("Password reset confirmed: $result");
    } catch (e) {
      print("Error confirming password reset: $e");
    }
  }

  /// Retrieve user session or other cloud data (placeholder).
  Future<Map<String, dynamic>> retrieveSession(String? sessionId) async {
    // Add Amplify DataStore or API Gateway logic here
    print("Retrieving session for ID: $sessionId");
    return {};
  }

  cancelForgotPassword() {}

  connectToDevice(GenericConnectorDevice<GenericConnectorDeviceState> device) {}

  disconnectDevice(
      GenericConnectorDevice<GenericConnectorDeviceState> device) {}

  startCgmSession(GenericConnectorDevice<GenericConnectorDeviceState> device,
      String sessionId, bool useDebugParams) {}

  setDebugParameters(GenericConnectorDevice<GenericConnectorDeviceState> device,
      IdiDebugParameters params) {}

  setProductionParameters(
      GenericConnectorDevice<GenericConnectorDeviceState> device, data) {}

  readProductionParameters(
      GenericConnectorDevice<GenericConnectorDeviceState> device) {}

  stopCgmSession(GenericConnectorDevice<GenericConnectorDeviceState> device) {}

  addCalibration(GenericConnectorDevice<GenericConnectorDeviceState> device,
      DataPoint value, bool calibrateAll) {}

  addDataPoint(DataPoint point) {}

  startScanning(String connectionId) {}

  stopScanning() {}

  startNfcPairing() {}

  stopNfcPairing() {}

  StreamSubscription? _systemResourceStateSubscription;
  StreamSubscription? _connectionEventSubscription;

  final StreamController<SystemResourceState> _systemResourceStateController =
      StreamController<SystemResourceState>.broadcast();

  final StreamController<GenericConnectionEvent> _connectionEventController =
      StreamController<GenericConnectionEvent>.broadcast();

  Stream<SystemResourceState> getSystemResourceStateStream() {
    return _systemResourceStateController.stream;
  }

  Stream<GenericConnectionEvent> getConnectionEventStream() {
    return _connectionEventController.stream;
  }

  // Subscribe to the GraphQL subscription for SystemResourceState
  Future<void> subscribeToSystemResourceState() async {
    try {
      // Create the GraphQL subscription for system resource state
      final operation = Amplify.API.subscribe(
        GraphQLRequest<String>(document: '''
          subscription OnCreateSystemResourceState {
            onCreateSystemResourceState {
              id
              status
              usage
              timestamp
            }
          }
          '''),
      );

      // Listen to the data coming from the subscription
      _systemResourceStateSubscription = operation.listen(
        (event) {
          // Decode the received data and push it to the stream
          if (event.data != null) {
            final data = jsonDecode(event.data!);
            final systemResourceState = SystemResourceState.fromJson(
                data['onCreateSystemResourceState']);
            _systemResourceStateController.add(systemResourceState);
          }
        },
        onError: (error) {
          print('Error receiving system resource state: $error');
        },
      );
    } catch (e) {
      print('Error subscribing to system resource state: $e');
    }
  }

  // Subscribe to the GraphQL subscription for GenericConnectionEvent
  Future<void> subscribeToConnectionEvent() async {
    try {
      // Create the GraphQL subscription for connection events
      final operation = Amplify.API.subscribe(
        GraphQLRequest<String>(document: '''
          subscription OnCreateConnectionEvent {
            onCreateConnectionEvent {
              deviceId
              eventType
              timestamp
            }
          }
          '''),
      );

      // Listen to the data coming from the subscription
      _connectionEventSubscription = operation.listen(
        (event) {
          // Decode the received data and push it to the stream
          if (event.data != null) {
            final data = jsonDecode(event.data!);
            final connectionEvent = GenericConnectionEvent.fromJson(
                data['onCreateConnectionEvent']);
            _connectionEventController.add(connectionEvent);
          }
        },
        onError: (error) {
          print('Error receiving connection event: $error');
        },
      );
    } catch (e) {
      print('Error subscribing to connection event: $e');
    }
  }

  // Cancel subscriptions when no longer needed
  void unsubscribe() {
    _systemResourceStateSubscription?.cancel();
    _connectionEventSubscription?.cancel();
  }

  // Dispose stream controllers
  void dispose() {
    _systemResourceStateController.close();
    _connectionEventController.close();
  }

  Future<User?> initializeAuthenticationState() async {
    try {
      final currentUser = await Amplify.Auth.getCurrentUser();

      if (currentUser != null) {
        print("User is already signed in: ${currentUser.userId}");

        return await fetchUser();
      } else {
        print("No user is signed in");
        return null; // No user signed in
      }
    } catch (e) {
      // In case of an error, return null
    }
    return null;
  }

  Future<User?> fetchUser() async {
      var currentUser = await Amplify.Auth.getCurrentUser();
      String userId = currentUser.userId;

      var userAttributes = await Amplify.Auth.fetchUserAttributes();
      //for (var attr in userAttributes) {
        //print('Key: ${attr.userAttributeKey}, Value: ${attr.value}');
      //}

      String email = userAttributes
          .firstWhere(
            (attr) => attr.userAttributeKey == AuthUserAttributeKey.email,
            orElse: () => const AuthUserAttribute(
                userAttributeKey: AuthUserAttributeKey.email, value: ''),
          )
          .value;

      String? firstName = userAttributes
          .firstWhere(
            (attr) => attr.userAttributeKey == AuthUserAttributeKey.givenName,
            orElse: () => const AuthUserAttribute(
                userAttributeKey: AuthUserAttributeKey.givenName, value: ''),
          )
          .value;

      String? lastName = userAttributes
          .firstWhere(
            (attr) => attr.userAttributeKey == AuthUserAttributeKey.familyName,
            orElse: () => const AuthUserAttribute(
                userAttributeKey: AuthUserAttributeKey.familyName, value: ''),
          )
          .value;

      String? phoneNumber = userAttributes
          .firstWhere(
            (attr) => attr.userAttributeKey == AuthUserAttributeKey.phoneNumber,
            orElse: () => const AuthUserAttribute(
                userAttributeKey: AuthUserAttributeKey.phoneNumber, value: ''),
          )
          .value;

      return User(
        id: userId,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
  }
}
