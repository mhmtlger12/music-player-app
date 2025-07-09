import 'package:flutter/material.dart';
import 'dart:math' as math;

class SettingsIconPainter extends CustomPainter {
  final Color color;

  SettingsIconPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    // Draw gear shape
    const int teeth = 8;
    const double toothHeight = 4.0;
    const double angle = 2 * math.pi / (teeth * 2);

    final path = Path();
    for (int i = 0; i < teeth * 2; i++) {
      final r = (i.isEven) ? radius : radius - toothHeight;
      final x = center.dx + r * math.cos(i * angle);
      final y = center.dy + r * math.sin(i * angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw inner circle
    canvas.drawCircle(center, radius / 2, paint);
  }

  @override
  bool shouldRepaint(covariant SettingsIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}