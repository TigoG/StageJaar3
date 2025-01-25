import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_theme_data.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_ca_connector_plugin/models/system_resource_state.dart';
import 'package:sen_gs_1_ca_connector_plugin/system_resource_controller.dart';
import 'package:sen_gs_1_ca_connector_plugin/web_connector_plugin.dart';
import 'package:sen_gs_1_web/cubit/app_cubit.dart';
import 'package:sen_gs_1_web/layouts/authentication_view.dart';
import 'package:sen_gs_1_web/layouts/master_layout_view.dart';

// Define a global navigator key
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SystemResourceController systemResourceController = SystemResourceController();
  final AppCubit appCubit = AppCubit(systemResourceController, WebConnectorPlugin());
    await _loadLocalization();
    await appCubit.initialize();

  runApp(App(systemResourceController: systemResourceController, appCubit: appCubit));
}

Future<void> _loadLocalization() async {
  try {
    String languageCode = PlatformDispatcher.instance.locale.languageCode;
    languageCode = languageCode.isNotEmpty ? languageCode : 'en';
    await LocalizationService.load(languageCode);
  } catch (e) {
    await LocalizationService.load('en'); // Fallback to English if loading fails
  }
}

class App extends StatelessWidget {
  const App({
    super.key,
    required SystemResourceController systemResourceController,
    required this.appCubit,
  }) : _systemResourceController = systemResourceController;

  final SystemResourceController _systemResourceController;
  final AppCubit appCubit;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _systemResourceController,
      child: BlocProvider.value(
        value: appCubit,
        child: const MainView(),
      ),
    );
  }
}

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey, // Assign the global navigator key here
      theme: SensibleThemeData.defaultTheme(),
      home: BlocBuilder<AppCubit, AppState>(
        buildWhen: (previous, current) =>
            previous.systemResourceState.cloudAuthenticationState !=
            current.systemResourceState.cloudAuthenticationState,
        builder: (context, appState) {
          switch (appState.systemResourceState.cloudAuthenticationState) {
            case CloudAuthenticationState.unAuthenticated:
              return const AuthenticationView();
            case CloudAuthenticationState.authenticated:
              return const MasterLayout();
            case CloudAuthenticationState.confirmSignUp:
            case CloudAuthenticationState.unknown:
            case CloudAuthenticationState.resetPassword:
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            default:
              return const Scaffold(
                body: Center(
                  child: Text("Unhandled state"),
                ),
              );
          }
        },
      ),
    );
  }
}
