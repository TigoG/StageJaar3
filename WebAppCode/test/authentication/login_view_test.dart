import 'dart:convert';

import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_ca_connector_plugin/system_resource_controller.dart';
import 'package:sen_gs_1_ca_connector_plugin/web/amplify_configuration.dart';
import 'package:sen_gs_1_ca_connector_plugin/web_connector_plugin.dart';
import 'package:sen_gs_1_web/cubit/app_cubit.dart';
import 'package:sen_gs_1_web/views/auth/login_view.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

Future<void> _configureAmplify() async {
  final auth = AmplifyAuthCognito();
  final api = AmplifyAPI();

  try {
    await Amplify.addPlugins([auth, api]);
    await Amplify.configure(jsonEncode(amplifyConfig));
  } catch (e) {
    print(e);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Widget loginView;
  final SystemResourceController connectionManagerController = SystemResourceController();

  setUpAll(() async {
    await _configureAmplify();
    LocalizationService.load("en");

    loginView = MaterialApp(
      theme: ThemeData(fontFamily: "OpenSans"),
      home: BlocProvider<AppCubit>(
        create: (_) => AppCubit(connectionManagerController, WebConnectorPlugin()),
        child: LoginView(onRegister: () {}, key: const ValueKey('loginView')),
      ),
    );
  });

  // Test to check if Email field is present
  testWidgets("Email field is present", (widgetTester) async {
    await widgetTester.pumpWidget(loginView);
    expect(find.byKey(const Key("Email")), findsOneWidget);
  });

  // Test to check if Password field is present
  testWidgets("Password field is present", (widgetTester) async {
    await widgetTester.pumpWidget(loginView);
    expect(find.byKey(const Key("Password")), findsOneWidget);
  });

  // Test if Login button is present
  testWidgets("Login button is present", (widgetTester) async {
    await widgetTester.pumpWidget(loginView);
    expect(find.byKey(const Key("Login")), findsOneWidget);
  });

  // Test case when no email and password provided
  testWidgets("No email and password provided", (widgetTester) async {
    await widgetTester.pumpWidget(loginView);
    await widgetTester.enterText(find.byKey(const Key("Email")), "");
    await widgetTester.enterText(find.byKey(const Key("Password")), "");

    await widgetTester.ensureVisible(find.byKey(const Key("Login")));
    await widgetTester.tap(find.byKey(const Key("Login")));
    await widgetTester.pumpAndSettle();

    expect(find.text("Email cannot be empty."), findsOneWidget);
    expect(find.text("Password cannot be empty."), findsOneWidget);
    expect(find.byKey(const Key("MessageText")), findsOneWidget);
  });

  // Test case when a valid email is provided but no password
  testWidgets("Valid email, no password", (widgetTester) async {
    await widgetTester.pumpWidget(loginView);

    await widgetTester.enterText(find.byKey(const Key("Email")), "test@test.com");
    await widgetTester.enterText(find.byKey(const Key("Password")), "");

    await widgetTester.ensureVisible(find.byKey(const Key("Login")));
    await widgetTester.tap(find.byKey(const Key("Login")));
    await widgetTester.pumpAndSettle();

    expect(find.text("Password cannot be empty."), findsOneWidget);
    expect(find.byKey(const Key("MessageText")), findsOneWidget);
  });

  // Test case for invalid email and password
  testWidgets("Invalid email and password", (widgetTester) async {
    await widgetTester.pumpWidget(loginView);

    await widgetTester.enterText(find.byKey(const Key("Email")), "invalidemail");
    await widgetTester.enterText(find.byKey(const Key("Password")), "short");

    await widgetTester.ensureVisible(find.byKey(const Key("Login")));
    await widgetTester.tap(find.byKey(const Key("Login")));
    await widgetTester.pumpAndSettle();

    expect(find.text("Email must be a valid email address."), findsOneWidget);
    expect(find.byKey(const Key("MessageText")), findsOneWidget);
  });
}