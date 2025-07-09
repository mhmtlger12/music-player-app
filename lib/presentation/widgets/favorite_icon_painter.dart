import 'package:flutter/material.dart';

class FavoriteIconPainter extends CustomPainter {
  final bool isFavorite;
  final Color activeColor;
  final Color? inactiveColor;

  FavoriteIconPainter({
    required this.isFavorite,
    this.activeColor = Colors.redAccent,
    this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isFavorite ? activeColor : (inactiveColor ?? Colors.white.withOpacity(0.8))
      ..style = isFavorite ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.35);
    path.cubicTo(size.width * 0.2, size.height * 0.1, 0, size.height * 0.6, size.width * 0.5, size.height * 0.9);
    path.cubicTo(size.width, size.height * 0.6, size.width * 0.8, size.height * 0.1, size.width * 0.5, size.height * 0.35);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant FavoriteIconPainter oldDelegate) {
    return oldDelegate.isFavorite != isFavorite;
  }
}