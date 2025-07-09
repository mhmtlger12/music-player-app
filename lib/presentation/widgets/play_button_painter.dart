import 'package:flutter/material.dart';
import 'dart:math' as math;

class PlayButtonPainter extends CustomPainter {
  final bool isPlaying;
  final double progress; // For animations

  PlayButtonPainter({required this.isPlaying, this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    if (isPlaying) {
      // Pause Icon (two rectangles)
      final barWidth = radius * 0.3;
      final barHeight = radius * 0.8;
      final gap = radius * 0.2;

      final leftBar = Rect.fromLTWH(
        center.dx - barWidth - gap / 2,
        center.dy - barHeight / 2,
        barWidth,
        barHeight,
      );
      final rightBar = Rect.fromLTWH(
        center.dx + gap / 2,
        center.dy - barHeight / 2,
        barWidth,
        barHeight,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(leftBar, const Radius.circular(4)), paint);
      canvas.drawRRect(RRect.fromRectAndRadius(rightBar, const Radius.circular(4)), paint);
    } else {
      // Play Icon (a triangle)
      final path = Path();
      final playRadius = radius * 0.7;
      path.moveTo(center.dx - playRadius * 0.4, center.dy - playRadius * 0.7);
      path.lineTo(center.dx - playRadius * 0.4, center.dy + playRadius * 0.7);
      path.lineTo(center.dx + playRadius * 0.6, center.dy);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PlayButtonPainter oldDelegate) {
    return oldDelegate.isPlaying != isPlaying || oldDelegate.progress != progress;
  }
}