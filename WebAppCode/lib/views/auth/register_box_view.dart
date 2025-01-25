import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_colors.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';
import 'package:sen_gs_1_ca_connector_plugin/localization_service.dart';

class RegisterBoxView extends StatefulWidget {
  const RegisterBoxView({super.key});

  @override
  _RegisterBoxViewState createState() => _RegisterBoxViewState();
}

class _RegisterBoxViewState extends State<RegisterBoxView> with SingleTickerProviderStateMixin {

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SingleChildScrollView(
      child: Container(
        height: screenHeight, // Sets the container height to full screen height
        padding: EdgeInsets.symmetric(vertical: SensibleDefaults.getPadding(context)), // Use responsive padding
        child: Center( // Centers the column vertically and horizontally
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/img/trendi_logo.png',
                height: screenHeight * 0.1,
              ),
              SizedBox(height: SensibleDefaults.getVerticalSpacing(context)),
              Text(
                LocalizationService.getString("register", "greetings"),
                style: TextStyle(
                  fontSize: SensibleDefaults.getFontSize(context),
                  color: SensibleColors.sensibleDeepBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
