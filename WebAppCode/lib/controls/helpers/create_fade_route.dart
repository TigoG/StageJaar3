import 'package:flutter/material.dart';

Route createFadeRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(animation);
      return FadeTransition(opacity: fadeAnimation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}
