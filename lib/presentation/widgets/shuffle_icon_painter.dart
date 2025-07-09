import 'package:flutter/material.dart';
import 'dart:math';

class ShuffleIconPainter extends CustomPainter {
  final bool isActive;
  final bool isSmartShuffle;
  final Color activeColor;
  final Color? inactiveColor;

  ShuffleIconPainter({
    this.isActive = false,
    this.isSmartShuffle = false,
    this.activeColor = Colors.orange,
    this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? activeColor : (inactiveColor ?? Colors.white.withOpacity(0.8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final path1 = Path();
    path1.moveTo(size.width * 0.1, size.height * 0.25);
    path1.cubicTo(
      size.width * 0.4, size.height * 0.25,
      size.width * 0.6, size.height * 0.75,
      size.width * 0.9, size.height * 0.75,
    );
    canvas.drawPath(path1, paint);

    final path2 = Path();
    path2.moveTo(size.width * 0.1, size.height * 0.75);
    path2.cubicTo(
      size.width * 0.4, size.height * 0.75,
      size.width * 0.6, size.height * 0.25,
      size.width * 0.9, size.height * 0.25,
    );
    canvas.drawPath(path2, paint);

    final arrowPaint = Paint()
      ..color = isActive ? activeColor : (inactiveColor ?? Colors.white.withOpacity(0.8))
      ..style = PaintingStyle.fill;

    final arrow1 = Path();
    arrow1.moveTo(size.width * 0.9, size.height * 0.75);
    arrow1.lineTo(size.width * 0.8, size.height * 0.65);
    arrow1.lineTo(size.width * 0.8, size.height * 0.85);
    arrow1.close();
    canvas.drawPath(arrow1, arrowPaint);

    final arrow2 = Path();
    arrow2.moveTo(size.width * 0.9, size.height * 0.25);
    arrow2.lineTo(size.width * 0.8, size.height * 0.15);
    arrow2.lineTo(size.width * 0.8, size.height * 0.35);
    arrow2.close();
    canvas.drawPath(arrow2, arrowPaint);

    if (isSmartShuffle) {
      final starPaint = Paint()
        ..color = activeColor
        ..style = PaintingStyle.fill;
      
      final starPath = Path();
      final centerX = size.width / 2;
      final centerY = size.height / 2;
      final radius = size.width * 0.15;
      const points = 5;
      const angle = (pi * 2) / (points * 2);

      starPath.moveTo(centerX + radius * cos(0), centerY + radius * sin(0));
      for (int i = 1; i <= points * 2; i++) {
        final r = i.isEven ? radius : radius / 2;
        starPath.lineTo(centerX + r * cos(angle * i), centerY + r * sin(angle * i));
      }
      starPath.close();
      canvas.drawPath(starPath, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant ShuffleIconPainter oldDelegate) {
    return oldDelegate.isActive != isActive || oldDelegate.isSmartShuffle != isSmartShuffle;
  }
}