import 'package:flutter/material.dart';

class EqualizerIconPainter extends CustomPainter {
  final Color color;

  EqualizerIconPainter({this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double barWidth = size.width / 5;

    // Draw 3 vertical bars
    for (int i = 0; i < 3; i++) {
      final double x = (i * 2 + 1) * barWidth;
      final double yStart = size.height * (0.2 + (i % 2) * 0.3);
      final double yEnd = size.height * (0.8 - (i % 2) * 0.3);
      canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), paint);
    }
  }

  @override
  bool shouldRepaint(covariant EqualizerIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}