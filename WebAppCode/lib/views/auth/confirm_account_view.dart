import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_web/controls/buttons/auth_button.dart';
import 'package:sen_gs_1_web/cubit/app_cubit.dart';
import 'package:sen_gs_1_web/controls/helpers/custom_text_field.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';

class ConfirmAccountView extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();

  ConfirmAccountView({super.key});

  void confirmAccount(BuildContext context) {
    if (emailController.text.isEmpty || verificationCodeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationService.getString("error", "empty_verification"))),
      );
      return;
    }

    context.read<AppCubit>().confirmAccount(
      emailController.text,
      verificationCodeController.text,
    ).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationService.getString("confirm_account", "confirm_succes"))),
      );
      emailController.clear();
      verificationCodeController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    });
  }

  void resendConfirmationCode(BuildContext context) {
    if (emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationService.getString("error", "empty_email"))),
      );
      return;
    }

    context.read<AppCubit>().resendConfirmationCode(emailController.text).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationService.getString("confirm_account", "resend"))),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: screenWidth * 0.9),
            child: Padding(
              padding: EdgeInsets.all(SensibleDefaults.getPadding(context)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(height: SensibleDefaults.getVerticalSpacing(context) * 2),
                  Text(
                    LocalizationService.getString("confirm_account", "confirm"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SensibleDefaults.getFontSize(context, baseSize: 20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
                  Text(
                    LocalizationService.getString("confirm_account", "enter_email"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: SensibleDefaults.getFontSize(context),
                    ),
                  ),
                  const SizedBox(height: 20),

                  CustomTextField(
                    label: LocalizationService.getString("login", "email"),
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    isError: false,
                    errorMessage: null,
                  ),
                  SizedBox(height: SensibleDefaults.getVerticalSpacing(context) / 2),

                  CustomTextField(
                    label: LocalizationService.getString("confirm_account", "verification"),
                    controller: verificationCodeController,
                    keyboardType: TextInputType.number,
                    isError: false,
                    errorMessage: null,
                  ),
                  SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),

                  AuthButton(
                    text: LocalizationService.getString("confirm_account", "confirm_account"),
                    onPressed: () => confirmAccount(context),
                  ),
                  SizedBox(height: SensibleDefaults.getVerticalSpacing(context) / 2),

                  TextButton(
                    onPressed: () => resendConfirmationCode(context),
                    child: Text(
                      LocalizationService.getString("confirm_account", "resend_code"),
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                        fontSize: SensibleDefaults.getFontSize(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
