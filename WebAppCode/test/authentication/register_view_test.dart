import 'package:amplify_api/amplify_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_ca_connector_plugin/system_resource_controller.dart';
import 'package:sen_gs_1_ca_connector_plugin/web/amplify_configuration.dart';
import 'package:sen_gs_1_ca_connector_plugin/web_connector_plugin.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'dart:convert';

import 'package:sen_gs_1_web/views/auth/register_view.dart';
import 'package:sen_gs_1_web/cubit/app_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Widget registerView;
  final SystemResourceController connectionManagerController =
      SystemResourceController();

  setUpAll(() async {

    await LocalizationService.load("en");

    await _configureAmplify();
    registerView = MaterialApp(
      theme: ThemeData(fontFamily: "OpenSans"),
      home: BlocProvider(
        create: (_) => AppCubit(connectionManagerController, WebConnectorPlugin()),
        child: const RegisterView(key: ValueKey('registerView')),
      ),
    );
  });

  testWidgets("Email field", (widgetTester) async {
    await widgetTester.pumpWidget(registerView);
    expect(find.byKey(const Key("Email")), findsOneWidget);
  });

  testWidgets("Password Field", (widgetTester) async {
    await widgetTester.pumpWidget(registerView);
    expect(find.byKey(const Key("Password")), findsOneWidget);
  });

  testWidgets("First Name Field", (widgetTester) async {
    await widgetTester.pumpWidget(registerView);
    expect(find.byKey(const Key("FirstName")), findsOneWidget);
  });

  testWidgets("Last Name Field", (widgetTester) async {
    await widgetTester.pumpWidget(registerView);
    expect(find.byKey(const Key("LastName")), findsOneWidget);
  });

  testWidgets("Date of Birth Field", (widgetTester) async {
    await widgetTester.pumpWidget(registerView);
    expect(find.byKey(const Key("DateOfBirth")), findsOneWidget);
  });

  testWidgets("Phone Number Field", (widgetTester) async {
    await widgetTester.pumpWidget(registerView);
    expect(find.byKey(const Key("PhoneNumber")), findsOneWidget);
  });

  testWidgets("Terms Checkbox", (widgetTester) async {
    await widgetTester.pumpWidget(registerView);
    final checkbox = find.byType(CheckboxListTile);
    expect(checkbox, findsOneWidget);

    expect((widgetTester.widget(checkbox) as CheckboxListTile).value, false);

    await widgetTester.tap(checkbox);
    await widgetTester.pump();

    expect((widgetTester.widget(checkbox) as CheckboxListTile).value, true);

    await widgetTester.tap(checkbox);
    await widgetTester.pump();

    expect((widgetTester.widget(checkbox) as CheckboxListTile).value, false);
  });

  testWidgets("No email, password, first name, and last name provided", (widgetTester) async {
    await widgetTester.pumpWidget(registerView);

    await widgetTester.enterText(find.byKey(const Key("Email")), "");
    await widgetTester.enterText(find.byKey(const Key("Password")), "");
    await widgetTester.enterText(find.byKey(const Key("FirstName")), "");
    await widgetTester.enterText(find.byKey(const Key("LastName")), "");
    await widgetTester.enterText(find.byKey(const Key("DateOfBirth")), "");
    await widgetTester.enterText(find.byKey(const Key("PhoneNumber")), "");

    final checkbox = find.byType(CheckboxListTile);
    await widgetTester.tap(checkbox);
    await widgetTester.pump();

    await widgetTester.ensureVisible(find.byKey(const Key("Register")));
    await widgetTester.tap(find.byKey(const Key("Register")));
    await widgetTester.pumpAndSettle();

    expect(find.text("One or more parameters are incorrect."), findsOneWidget);
    expect(find.text("Email cannot be empty."), findsOneWidget);
    expect(find.text("Password cannot be empty."), findsOneWidget);
    expect(find.text("First name cannot be empty."), findsOneWidget);
    expect(find.text("Last name cannot be empty."), findsOneWidget);
    expect(find.text("Date of birth cannot be empty."), findsOneWidget);
    expect(find.text("Phone number cannot be empty."), findsOneWidget);
  });

  testWidgets("Invalid email format", (widgetTester) async {
    await widgetTester.pumpWidget(registerView);

    await widgetTester.enterText(find.byKey(const Key("Email")), "invalid-email");
    await widgetTester.enterText(find.byKey(const Key("Password")), "ValidPassword123!");

    final checkbox = find.byType(CheckboxListTile);
    await widgetTester.tap(checkbox);
    await widgetTester.pump();

    await widgetTester.ensureVisible(find.byKey(const Key("Register")));
    await widgetTester.tap(find.byKey(const Key("Register")));
    await widgetTester.pumpAndSettle();

    expect(find.text("Email must be a valid email address."), findsOneWidget);
  });

  
testWidgets("Valid fields registration", (widgetTester) async {
  await widgetTester.pumpWidget(registerView);

  await widgetTester.enterText(find.byKey(const Key("Email")), "test@example.com");
  await widgetTester.enterText(find.byKey(const Key("Password")), "ValidPassword123");
  await widgetTester.enterText(find.byKey(const Key("FirstName")), "John");
  await widgetTester.enterText(find.byKey(const Key("LastName")), "Johnson");
  await widgetTester.enterText(find.byKey(const Key("DateOfBirth")), "1990-01-01");
  await widgetTester.enterText(find.byKey(const Key("PhoneNumber")), "+1234567890");

  final checkbox = find.byType(CheckboxListTile);
  await widgetTester.tap(checkbox);
  await widgetTester.pump();

  await widgetTester.ensureVisible(find.byKey(const Key("Register")));
  await widgetTester.tap(find.byKey(const Key("Register")));

  expect(find.text("Create Account"), findsOneWidget);
});
}

Future<void> _configureAmplify() async {
  final auth = AmplifyAuthCognito();
  final api = AmplifyAPI();

  try {
    await Amplify.addPlugins([auth, api]);
    await Amplify.configure(jsonEncode(amplifyConfig));
    debugPrint('Amplify configured successfully for tests');
  } catch (e) {
    debugPrint("Amplify configuration error during tests: $e");
  }
}
