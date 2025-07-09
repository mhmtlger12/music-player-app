import 'package:flutter/material.dart';

enum SkipDirection { forward, backward }

class SkipButtonPainter extends CustomPainter {
  final SkipDirection direction;

  SkipButtonPainter({required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final triangleWidth = size.width * 0.4;
    final triangleHeight = size.height * 0.5;

    final path = Path();

    if (direction == SkipDirection.forward) {
      // Forward Icon (two triangles)
      path.moveTo(center.dx - triangleWidth, center.dy - triangleHeight / 2);
      path.lineTo(center.dx, center.dy);
      path.lineTo(center.dx - triangleWidth, center.dy + triangleHeight / 2);
      path.close();

      path.moveTo(center.dx, center.dy - triangleHeight / 2);
      path.lineTo(center.dx + triangleWidth, center.dy);
      path.lineTo(center.dx, center.dy + triangleHeight / 2);
      path.close();
    } else {
      // Backward Icon (two triangles)
      path.moveTo(center.dx + triangleWidth, center.dy - triangleHeight / 2);
      path.lineTo(center.dx, center.dy);
      path.lineTo(center.dx + triangleWidth, center.dy + triangleHeight / 2);
      path.close();

      path.moveTo(center.dx, center.dy - triangleHeight / 2);
      path.lineTo(center.dx - triangleWidth, center.dy);
      path.lineTo(center.dx, center.dy + triangleHeight / 2);
      path.close();
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SkipButtonPainter oldDelegate) {
    return oldDelegate.direction != direction;
  }
}