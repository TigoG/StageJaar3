import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_colors.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_web/controls/buttons/auth_button.dart';
import 'package:sen_gs_1_web/views/auth/forgot_password_view.dart';
import 'package:sen_gs_1_web/cubit/app_cubit.dart';
import 'package:sen_gs_1_web/controls/helpers/custom_text_field.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';

class LoginView extends StatefulWidget {
  final VoidCallback onRegister;

  const LoginView({super.key, required this.onRegister});

  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoading = false;
  String? messageText;
  bool isError = false;
  String? emailError;
  String? passwordError;
  bool showForgotPassword = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void checkRequiredFields() {
    RegExp emailPattern =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");

    if (emailController.text.isEmpty) {
      setState(() {
        isError = true;
        emailError = LocalizationService.getString("error", "empty_email");
      });
    } else if (!emailPattern.hasMatch(emailController.text)) {
      setState(() {
        isError = true;
        emailError = LocalizationService.getString("error", "email_invalid");
      });
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        isError = true;
        passwordError = LocalizationService.getString("error", "empty_password");
      });
    }

    if (isError) {
      messageText = LocalizationService.getString("error", "incorrect_params");
    }
  }

  void login() {
    Amplify.Auth.signOut(); // Sign out before signing in
    // Set loading state to true at the start of the login process
    setState(() {
      isLoading = true; // Start loading
      messageText = null;
      isError = false;
    });

    checkRequiredFields();

    if (!isError) {
      context
          .read<AppCubit>()
          .signIn(emailController.text, passwordController.text)
          .then((_) {})
          .catchError((error) {
        if (mounted) {
          setState(() {
            isError = true;
            isLoading = false; // Stop loading after error
          });
        }
      }).whenComplete(() {
        if (mounted) {
          isError = true;
          messageText = "Username or password is incorrect.";
          setState(() {
            isLoading = false; // Stop loading in any case
          });
        }
      });
    } else {
      setState(() {
        isLoading = false; // Stop loading if there are validation errors
      });
    }
  }

  void showResetPasswordView() {
    setState(() {
      showForgotPassword = true;
    });
  }

  void resetToLoginView(String _) {
    setState(() {
      showForgotPassword = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(
            bottom: SensibleDefaults.getVerticalSpacing(context)),
        padding: EdgeInsets.symmetric(
            horizontal: SensibleDefaults.getMargin(context)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
                Image.asset(
                  "assets/img/trendi_logo.png",
                  height: screenHeight * 0.1,
                ),
                SizedBox(
                    height: SensibleDefaults.getVerticalSpacing(context) * 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: !showForgotPassword
                      ? Column(
                          key: const ValueKey("LoginView"),
                          children: [
                            CustomTextField(
                              key: const Key("Email"),
                              label: LocalizationService.getString("login","email"),
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              isError: emailError != null,
                              errorMessage: emailError,
                            ),
                            SizedBox(
                                height: SensibleDefaults.getVerticalSpacing(
                                    context)),
                            CustomTextField(
                              key: const Key("Password"),
                              label: LocalizationService.getString("login","password"),
                              controller: passwordController,
                              obscureText: true,
                              isError: passwordError != null,
                              errorMessage: passwordError,
                            ),
                            SizedBox(
                                height: SensibleDefaults.getVerticalSpacing(
                                    context)),
                            if (messageText != null)
                              Text(
                                messageText!,
                                key: const Key("MessageText"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize:
                                      SensibleDefaults.getFontSize(context),
                                  color: isError ? Colors.red : Colors.grey,
                                ),
                              ),
                            SizedBox(
                                height: SensibleDefaults.getVerticalSpacing(
                                    context)),
                            TextButton(
                              key: const Key("ForgotPassword"),
                              onPressed: showResetPasswordView,
                              style: TextButton.styleFrom(
                                minimumSize: const Size(double.infinity, 40),
                                padding: EdgeInsets.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                LocalizationService.getString("login","forgot_password"),
                                style: TextStyle(
                                  color: SensibleColors.sensibleDeepBlue,
                                  fontSize:
                                      SensibleDefaults.getFontSize(context),
                                ),
                              ),
                            ),
                            SizedBox(
                                height: SensibleDefaults.getVerticalSpacing(
                                    context)),
                            isLoading
                                ? const CircularProgressIndicator()
                                : AuthButton(
                                    key: const Key("Login"),
                                    text: LocalizationService.getString("login","login"),
                                    onPressed: login,
                                  ),
                          ],
                        )
                      : ForgetPasswordView(
                          key: const ValueKey("ForgotPasswordView"),
                          onResetPassword: resetToLoginView,
                        ),
                ),
                SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
                TextButton(
                  key: const Key("CreateAccount"),
                  onPressed: widget.onRegister,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(
                        double.infinity, 40),
                    padding: EdgeInsets.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: LocalizationService.getString("login","new_user"),
                          style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context),
                          ),
                        ),
                        TextSpan(
                          text: LocalizationService.getString("login","register"),
                          style: TextStyle(
                            fontSize: SensibleDefaults.getFontSize(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
