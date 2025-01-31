import 'package:flutter/material.dart';

class SensibleDefaults {
  static const tightPadding = 30.0;

  static const WarningTitleStyle = TextStyle(
    color: Colors.deepOrange,
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  static const TextStyle WarningDetailsStyle = TextStyle(
    color: Colors.deepOrange,
    fontSize: 16,
  );

  //According to Bootstrap the normal screen size is 768px of a phone
  static int phoneSize = 768;

  // Responsive values based on screen width
  static double getPadding(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 1920 ? 40.0 : 20.0;
  }

  static double getMargin(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return screenWidth > 1920 ? 80.0 : 60.0;
  }

  static double getFontSize(BuildContext context, {double baseSize = 16.0}) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1920) {
      return baseSize * 1.5;
    }
    return baseSize;
  }

  static BorderRadius getBorderRadius() {
    return BorderRadius.circular(16);
  }

  static double getVerticalSpacing(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return screenHeight * 0.02;
  }
}
