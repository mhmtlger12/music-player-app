import 'package:flutter/material.dart';

class SleepTimerIconPainter extends CustomPainter {
  final bool isActive;
  final Color activeColor;
  final Color? inactiveColor;

  SleepTimerIconPainter({
    this.isActive = false,
    this.activeColor = Colors.orange,
    this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isActive ? activeColor : (inactiveColor ?? Colors.white.withOpacity(0.8))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw clock circle
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2.2, paint);

    // Draw clock hands
    final handPaint = Paint()
      ..color = isActive ? activeColor : (inactiveColor ?? Colors.white.withOpacity(0.8))
      ..strokeWidth = 2.0;
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width / 2, size.height * 0.2),
      handPaint,
    );
    canvas.drawLine(
      Offset(size.width / 2, size.height / 2),
      Offset(size.width * 0.75, size.height / 2),
      handPaint,
    );

    // Draw Zzz for sleep
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'Z',
        style: TextStyle(
          color: isActive ? activeColor : (inactiveColor ?? Colors.white.withOpacity(0.8)),
          fontSize: size.height * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width * 0.1, size.height * 0.05));
  }

  @override
  bool shouldRepaint(covariant SleepTimerIconPainter oldDelegate) {
    return oldDelegate.isActive != isActive;
  }
}