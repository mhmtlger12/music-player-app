import 'dart:math';
import 'package:flutter/material.dart';

class AudioVisualizerPainter extends CustomPainter {
  final Animation<double> animation;
  final int barCount;
  final Color color;

  AudioVisualizerPainter({
    required this.animation,
    this.barCount = 30,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final barWidth = size.width / (barCount * 2);
    final center = size.height / 2;

    for (int i = 0; i < barCount; i++) {
      // Her bir çubuğun yüksekliğini animasyon ve sinüs fonksiyonu ile dinamik hale getiriyoruz.
      // Bu, müziğin ritmini taklit eden rastgele ve akıcı bir hareket sağlar.
      final animationValue = animation.value;
      final sineValue = sin((animationValue * 360 + i * 20) * (pi / 180));
      final barHeight = (size.height * 0.4) * (0.5 + 0.5 * sineValue);

      final left = i * barWidth * 2 + barWidth / 2;
      final top = center - barHeight / 2;
      final right = left + barWidth;
      final bottom = center + barHeight / 2;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(left, top, right, bottom),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant AudioVisualizerPainter oldDelegate) {
    return false;
  }
}