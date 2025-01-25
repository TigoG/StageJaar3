import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_ca_connector_plugin/web/amplify_configuration.dart';
import 'package:sen_gs_1_web/layouts/master_layout_view.dart';
import 'package:sen_gs_1_web/layouts/authentication_view.dart';
import 'package:sen_gs_1_web/views/connection/connection_list_view.dart';

// Initialize Amplify with plugins (Auth and API in this case)
Future<void> _configureAmplify() async {
  final auth = AmplifyAuthCognito();
  final api = AmplifyAPI();

  try {
    await Amplify.addPlugins([auth, api]);
    await Amplify.configure(jsonEncode(amplifyConfig));
  } catch (e) {
    print("Amplify configuration error: $e");
  }
}

Future<void> signInUser(String username, String password) async {
  try {
    final result = await Amplify.Auth.signIn(
      username: username,
      password: password,
    );
    await AuthSignInStep.done;
  } on AuthException catch (e) {
    safePrint('Error signing in: ${e.message}');
  }
}

void main() {
  // Configure Amplify before running tests
  setUp(() async {
    await _configureAmplify();
    await LocalizationService.load("en");
  });

  testWidgets('MasterLayout displays correct view when user is authenticated', (WidgetTester tester) async {
    CognitoAuthUser? authUser;

    try {
      // Simulate sign-in with correct credentials
      final signInResult = await Amplify.Auth.signIn(
        username: 'tigogoes11@gmail.com',
        password: '@TigoGoes11',	
      );
      if (signInResult.isSignedIn) {
        // Fetch the current authenticated user and cast to CognitoAuthUser
        authUser = await Amplify.Auth.getCurrentUser() as CognitoAuthUser?;
      }
    } catch (e) {
      print("Sign-in failed: $e");
    }

    // Ensure that the sign-in was successful and the user is authenticated
    expect(authUser, isNotNull);

    // Build the widget with the appropriate view based on user authentication
    await tester.pumpWidget(
      MaterialApp(
        home: authUser != null ? MasterLayout() : AuthenticationView(),
      ),
    );

    // Wait for the widget to settle and check that the MasterLayout is displayed
    await tester.pumpAndSettle();
    expect(find.byType(MasterLayout), findsOneWidget);
  });

  testWidgets('MasterLayout displays ConnectionListView with correct userId', (WidgetTester tester) async {
    CognitoAuthUser? authUser;

    try {
      // Simulate sign-in with correct credentials
      final signInResult = await Amplify.Auth.signIn(
        username: 'testuser@example.com',
        password: 'TestPassword123',
      );
      if (signInResult.isSignedIn) {
        // Fetch the current authenticated user and cast to CognitoAuthUser
        authUser = await Amplify.Auth.getCurrentUser() as CognitoAuthUser?;
      }
    } catch (e) {
      print("Sign-in failed: $e");
    }

    // Build the widget with MasterLayout
    await tester.pumpWidget(
      MaterialApp(
        home: MasterLayout(),
      ),
    );

    // Ensure the ConnectionListView is displayed
    await tester.pumpAndSettle();
    expect(find.byType(ConnectionListView), findsOneWidget);

    // Get the ConnectionListView instance and verify userId
    final connectionListView = tester.widget<ConnectionListView>(find.byType(ConnectionListView));
    expect(connectionListView.userId, authUser?.userId);
  });

  testWidgets('AuthenticationView is shown when user is not authenticated', (WidgetTester tester) async {
    // Build the widget with AuthenticationView for an unauthenticated user
    await tester.pumpWidget(
      MaterialApp(
        home: AuthenticationView(),
      ),
    );

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify that the AuthenticationView is displayed
    expect(find.byType(AuthenticationView), findsOneWidget);
  });
}
