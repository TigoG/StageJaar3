import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';
import 'package:sen_gs_1_web/controls/buttons/auth_button.dart';
import 'package:sen_gs_1_web/cubit/app_cubit.dart';
import 'package:sen_gs_1_web/controls/helpers/custom_text_field.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';

class ForgetPasswordView extends StatelessWidget {
  final TextEditingController resetEmailController = TextEditingController();
  final Function(String) onResetPassword;

  ForgetPasswordView({super.key, required this.onResetPassword});

  void resetPassword(BuildContext context) {
    if (resetEmailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationService.getString("error", "empty_email"))),
      );
      return;
    }

    context.read<AppCubit>().forgotPassword(resetEmailController.text).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationService.getString("forgot_password", "email_sent"))),
      );
      resetEmailController.clear();
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: SensibleDefaults.getPadding(context)),
        child: Center( // Center the content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context) * 3),
              Text(
                LocalizationService.getString("forgot_password", "forgot_password"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SensibleDefaults.getFontSize(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              Text(
                LocalizationService.getString("forgot_password", "enter_email"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: SensibleDefaults.getFontSize(context),
                ),
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              CustomTextField(
                key: const Key("ResetEmail"),
                label: LocalizationService.getString("login", "email"),
                controller: resetEmailController,
                keyboardType: TextInputType.emailAddress,
                isError: false,
                errorMessage: null,
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              AuthButton(
                key: const Key("ResetPassword"),
                text: LocalizationService.getString("forgot_password", "reset_password"),
                onPressed: () => resetPassword(context),
              ),
              TextButton(
                key: const Key("BackToLogin"),
                onPressed: () => onResetPassword(""),
                child: Text(
                  LocalizationService.getString("forgot_password", "back"),
                  style: TextStyle(
                    fontSize: SensibleDefaults.getFontSize(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
