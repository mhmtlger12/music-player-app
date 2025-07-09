import 'dart:math' as math;
import 'package:flutter/material.dart';

class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  WaveformPainter({required this.animation, this.color = Colors.white})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    final centerY = size.height / 2;
    final width = size.width;
    final amplitude = size.height / 4 * animation.value;

    path.moveTo(0, centerY);

    for (double x = 0; x < width; x++) {
      final sineValue = math.sin(x * 0.05 + animation.value * 8);
      final y = centerY + sineValue * amplitude;
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return false;
  }
}