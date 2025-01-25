import 'package:flutter/material.dart';

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();

    // Flip the canvas vertically
    canvas.scale(1, -1); // This flips the Y-axis
    canvas.translate(0, -size.height); // Move origin to the top-left corner

    paint.color = const Color.fromRGBO(99, 157, 214, 0.6);
    
    // Draw the first wave
    Path path = Path();
    path.lineTo(0, 0);
    path.cubicTo(0, 0, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, size.width, size.height * 0.55, size.width, size.height * 0.55);
    path.cubicTo(size.width, size.height * 0.55, size.width * 0.97, size.height * 0.57, size.width * 0.97, size.height * 0.57);
    path.cubicTo(size.width * 0.93, size.height * 0.59, size.width * 0.87, size.height * 0.63, size.width * 0.8, size.height * 0.55);
    path.cubicTo(size.width * 0.73, size.height * 0.48, size.width * 0.67, size.height * 0.29, size.width * 0.6, size.height / 5);
    path.cubicTo(size.width * 0.53, size.height * 0.11, size.width * 0.47, size.height * 0.11, size.width * 0.4, size.height * 0.22);
    path.cubicTo(size.width / 3, size.height / 3, size.width * 0.27, size.height * 0.56, size.width / 5, size.height * 0.7);
    path.cubicTo(size.width * 0.13, size.height * 0.85, size.width * 0.07, size.height * 0.93, size.width * 0.03, size.height * 0.96);
    path.cubicTo(size.width * 0.03, size.height * 0.96, 0, size.height, 0, size.height);
    path.cubicTo(0, size.height, 0, 0, 0, 0);
    path.cubicTo(0, 0, 0, 0, 0, 0);
    canvas.drawPath(path, paint);

    paint.color = const Color.fromRGBO(99,157,214, 0.6);
    path = Path();
    path.lineTo(0, 0);
    path.cubicTo(0, 0, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, size.width, size.height, size.width, size.height);
    path.cubicTo(size.width, size.height, size.width * 0.97, size.height * 0.96, size.width * 0.97, size.height * 0.96);
    path.cubicTo(size.width * 0.93, size.height * 0.92, size.width * 0.87, size.height * 0.83, size.width * 0.8, size.height * 0.83);
    path.cubicTo(size.width * 0.73, size.height * 0.83, size.width * 0.67, size.height * 0.92, size.width * 0.6, size.height * 0.83);
    path.cubicTo(size.width * 0.53, size.height * 0.75, size.width * 0.47, size.height / 2, size.width * 0.4, size.height * 0.54);
    path.cubicTo(size.width / 3, size.height * 0.58, size.width * 0.27, size.height * 0.92, size.width / 5, size.height * 0.9);
    path.cubicTo(size.width * 0.13, size.height * 0.88, size.width * 0.07, size.height / 2, size.width * 0.03, size.height * 0.32);
    path.cubicTo(size.width * 0.03, size.height * 0.32, 0, size.height * 0.13, 0, size.height * 0.13);
    path.cubicTo(0, size.height * 0.13, 0, 0, 0, 0);
    path.cubicTo(0, 0, 0, 0, 0, 0);
    canvas.drawPath(path, paint);

    paint.color = const Color.fromRGBO(99,157,214, 0.6);
    path = Path();
    path.lineTo(0, 0);
    path.cubicTo(0, 0, size.width, 0, size.width, 0);
    path.cubicTo(size.width, 0, size.width, size.height * 0.62, size.width, size.height * 0.62);
    path.cubicTo(size.width, size.height * 0.62, size.width * 0.97, size.height * 0.55, size.width * 0.97, size.height * 0.55);
    path.cubicTo(size.width * 0.93, size.height * 0.48, size.width * 0.87, size.height * 0.34, size.width * 0.8, size.height * 0.28);
    path.cubicTo(size.width * 0.73, size.height / 5, size.width * 0.67, size.height / 5, size.width * 0.6, size.height * 0.42);
    path.cubicTo(size.width * 0.53, size.height * 0.62, size.width * 0.47, size.height * 1.03, size.width * 0.4, size.height);
    path.cubicTo(size.width / 3, size.height * 0.96, size.width * 0.27, size.height * 0.49, size.width / 5, size.height * 0.35);
    path.cubicTo(size.width * 0.14, size.height * 0.22, size.width * 0.07, size.height * 0.42, size.width * 0.04, size.height * 0.52);
    path.cubicTo(size.width * 0.04, size.height * 0.52, 0, size.height * 0.63, 0, size.height * 0.63);
    path.cubicTo(0, size.height * 0.63, 0, 0, 0, 0);
    canvas.drawPath(path, paint);

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
