import 'package:flutter/material.dart';

class LibraryIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1;

    final double lineSpacing = size.height * 0.3;
    final double lineLength = size.width * 0.8;
    final double startX = (size.width - lineLength) / 2;

    // Draw three horizontal lines
    for (int i = 0; i < 3; i++) {
      final y = (size.height / 2) - (lineSpacing * (1 - i));
      canvas.drawLine(Offset(startX, y), Offset(startX + lineLength, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}