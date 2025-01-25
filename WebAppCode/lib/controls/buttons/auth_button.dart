import 'package:flutter/material.dart';
import 'package:sen_gs_1_ca_connector_plugin/constant/sensible_defaults.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const AuthButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: EdgeInsets.only(
        bottom: SensibleDefaults.getVerticalSpacing(context),
      ),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.symmetric(
            vertical: SensibleDefaults.getPadding(context),
            horizontal: SensibleDefaults.getPadding(context),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: SensibleDefaults.getBorderRadius(),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: SensibleDefaults.getFontSize(context),
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
