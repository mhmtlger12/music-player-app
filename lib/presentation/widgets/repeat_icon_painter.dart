import 'package:flutter/material.dart';
import 'dart:math' as math;

class RepeatIconPainter extends CustomPainter {
  final bool isActive;
  final bool isRepeatOne; // For "repeat one" mode
  final Color activeColor;
  final Color? inactiveColor;

  RepeatIconPainter({
    this.isActive = false,
    this.isRepeatOne = false,
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

    final rect = Rect.fromLTWH(size.width * 0.1, size.height * 0.2, size.width * 0.8, size.height * 0.6);
    final path = Path();
    path.addArc(rect, math.pi * 0.25, math.pi * 1.75);
    canvas.drawPath(path, paint);

    // Draw arrows
    final arrowPaint = Paint()
      ..color = isActive ? activeColor : (inactiveColor ?? Colors.white.withOpacity(0.8))
      ..style = PaintingStyle.fill;

    final arrow1 = Path();
    arrow1.moveTo(size.width * 0.8, size.height * 0.1);
    arrow1.lineTo(size.width * 0.9, size.height * 0.3);
    arrow1.lineTo(size.width * 0.7, size.height * 0.3);
    arrow1.close();
    canvas.drawPath(arrow1, arrowPaint);

    final arrow2 = Path();
    arrow2.moveTo(size.width * 0.2, size.height * 0.9);
    arrow2.lineTo(size.width * 0.1, size.height * 0.7);
    arrow2.lineTo(size.width * 0.3, size.height * 0.7);
    arrow2.close();
    canvas.drawPath(arrow2, arrowPaint);

    // Draw "1" for repeat one mode
    if (isRepeatOne) {
      final textSpan = TextSpan(
        text: '1',
        style: TextStyle(
          color: isActive ? activeColor : (inactiveColor ?? Colors.white.withOpacity(0.8)),
          fontSize: size.height * 0.4,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(size.width / 2 - textPainter.width / 2, size.height / 2 - textPainter.height / 2));
    }
  }

  @override
  bool shouldRepaint(covariant RepeatIconPainter oldDelegate) {
    return oldDelegate.isActive != isActive || oldDelegate.isRepeatOne != isRepeatOne;
  }
}