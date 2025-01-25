import 'package:flutter/material.dart';
import 'package:sen_gs_1_web/views/auth/login_view.dart';
import 'package:sen_gs_1_web/views/auth/register_box_view.dart';
import 'package:sen_gs_1_web/views/auth/register_view.dart';
import 'package:sen_gs_1_web/widgets/wave_painter.dart';

class AuthenticationView extends StatefulWidget {
  const AuthenticationView({super.key});

  @override
  _AuthenticationViewState createState() => _AuthenticationViewState();
}

class _AuthenticationViewState extends State<AuthenticationView> {
  bool _isLoginView = true;

  void _toggleView() {
    setState(() {
      _isLoginView = !_isLoginView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine if the device is mobile
    bool isMobile = screenWidth < 700;

    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CustomPaint(
                painter: WavePainter(),
                child: const SizedBox(
                  height: 150,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              // Adjust width based on mobile or web
              width: isMobile ? screenWidth * 0.80 : (_isLoginView ? screenWidth * 0.35 : screenWidth * 0.45),
              margin: EdgeInsets.only(
                left: isMobile ? screenWidth * 0.1 : (_isLoginView ? screenWidth * 0.1 : 0),
                right: isMobile ? screenWidth * 0.1 : (_isLoginView ? 0 : screenWidth * 0.1),
              ),
              decoration: const BoxDecoration(
                color: Color.fromRGBO(244, 249, 255, 0.8),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _isLoginView
                    ? LoginView(onRegister: _toggleView, key: const ValueKey('loginView'))
                    : (isMobile 
                        ? const SizedBox.shrink() // Hide RegisterBoxView on mobile
                        : const RegisterBoxView(key: ValueKey('registerBoxView'))), // Show RegisterBoxView on web
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                // Adjust the width for the right side to be larger on mobile
                width: isMobile ? screenWidth * 0.80 : screenWidth * 0.35,
                height: double.infinity,
                margin: EdgeInsets.only(right: screenWidth * 0.1),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _isLoginView
                      ? const SizedBox.shrink(key: ValueKey('empty'))
                      : RegisterView(onLogin: _toggleView, key: const ValueKey('registerView')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
