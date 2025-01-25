import 'dart:convert';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sen_gs_1_ca_connector_plugin/web/amplify_configuration.dart';

// Mock classes for Amplify plugins
class MockAmplifyAuthCognito extends Mock implements AmplifyAuthCognito {}
class MockAmplifyAPI extends Mock implements AmplifyAPI {}
class MockAmplifyAuthProviderRepository extends Mock implements AmplifyAuthProviderRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAmplifyAuthCognito mockAuth;
  late MockAmplifyAPI mockAPI;
  late MockAmplifyAuthProviderRepository mockAuthProviderRepo;

  setUp(() async {
    // Initialize mock objects
    mockAuth = MockAmplifyAuthCognito();
    mockAPI = MockAmplifyAPI();
    mockAuthProviderRepo = MockAmplifyAuthProviderRepository();

    // Mock the Amplify.configure method
    final mockConfigJson = jsonEncode({
      "Auth": {
        "plugins": {
          "awsCognitoAuthPlugin": {
            "UserAgent": "aws-amplify-flutter/0.1.0",
            "Version": "1.0"
          }
        }
      }
    });

    // Mock the addPlugins method
    when(Amplify.addPlugins([mockAuth, mockAPI])).thenAnswer((_) async {
      print("Amplify.addPlugins called!");
    });

    // Mock the Amplify.configure method with a specific config string
    when(Amplify.configure(mockConfigJson)).thenAnswer((_) async {
      print("Amplify.configure called with config: $mockConfigJson");
    });

    // Mock the addPlugin method on AmplifyAuthCognito
    when(mockAuth.addPlugin(authProviderRepo: mockAuthProviderRepo)).thenAnswer((_) async {
      print("AmplifyAuthCognito.addPlugin called!");
    });

    // Add mock plugins to Amplify
    await Amplify.addPlugins([mockAuth, mockAPI]);
  });

  test('should configure Amplify with mocked plugins', () async {
    try {
      // Call the _configureAmplify method
      await _configureAmplify();

      // Ensure that Amplify.addPlugins() is called with the expected plugins
      verify(Amplify.addPlugins([mockAuth, mockAPI])).called(1);

      // Ensure Amplify.configure() is called with the correct mock config
      //verify(Amplify.configure(any)).called(1); // Still use `any` here because you want to allow any JSON structure

      // Ensure the addPlugin method was called with the correct authProviderRepo
      verify(mockAuth.addPlugin(authProviderRepo: mockAuthProviderRepo)).called(1);

      print("Amplify is configured with mocked plugins successfully.");
    } catch (e) {
      fail('Amplify configuration failed with mock: $e');
    }
  });
}

// Your actual _configureAmplify method from the app
Future<void> _configureAmplify() async {
  final auth = AmplifyAuthCognito();
  final api = AmplifyAPI();
  final authProviderRepo = AmplifyAuthProviderRepository();

  try {
    // Add the plugins with the specified arguments
    await Amplify.addPlugins([auth, api]);

    // Use the real amplifyConfig object (you can mock it as part of the testing if needed)
    await Amplify.configure(jsonEncode(amplifyConfig));  // This uses the actual `amplifyConfig` imported from your project

  } catch (e) {
    print(e);
  }
}
