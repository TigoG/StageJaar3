import 'package:flutter_test/flutter_test.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';

void main() {
  // Ensure the widgets are properly initialized before the tests
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('English Localization Tests', () {
    test('Load English localization and verify strings', () async {
      await LocalizationService.load('en');

      expect(LocalizationService.getString('login', 'email'), 'Email');
      expect(LocalizationService.getString('login', 'password'), 'Password');
      expect(LocalizationService.getString('login', 'register'), 'Sign up');
      expect(LocalizationService.getString('login', 'forgot_password'), 'I forgot my password');
      expect(LocalizationService.getString('error', 'incorrect_params'), 'One or more parameters are incorrect.');
    });

    test('Verify error messages in English', () async {
      await LocalizationService.load('en');

      expect(LocalizationService.getString('error', 'empty_email'), 'Email cannot be empty.');
      expect(LocalizationService.getString('error', 'empty_password'), 'Password cannot be empty.');
      expect(LocalizationService.getString('error', 'email_invalid'), 'Email must be a valid email address.');
      expect(LocalizationService.getString('error', 'incorrect_params'), 'One or more parameters are incorrect.');
    });
  });
}
