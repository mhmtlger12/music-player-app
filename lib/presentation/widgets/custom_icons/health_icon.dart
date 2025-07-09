import 'package:flutter/material.dart';

class HealthIcon extends StatelessWidget {
  final double size;
  final Color color;

  const HealthIcon({super.key, this.size = 24.0, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _HealthIconPainter(color: color),
    );
  }
}

class _HealthIconPainter extends CustomPainter {
  final Color color;
  _HealthIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Kalp şekli
    final Path heartPath = Path();
    heartPath.moveTo(size.width * 0.5, size.height * 0.35);
    heartPath.cubicTo(size.width * 0.2, size.height * 0.1, size.width * 0.0, size.height * 0.6, size.width * 0.5, size.height * 0.9);
    heartPath.moveTo(size.width * 0.5, size.height * 0.35);
    heartPath.cubicTo(size.width * 0.8, size.height * 0.1, size.width * 1.0, size.height * 0.6, size.width * 0.5, size.height * 0.9);
    
    canvas.drawPath(heartPath, paint);

    // Nabız çizgisi
    final Path pulsePath = Path();
    pulsePath.moveTo(size.width * 0.25, size.height * 0.6);
    pulsePath.lineTo(size.width * 0.4, size.height * 0.6);
    pulsePath.lineTo(size.width * 0.45, size.height * 0.5);
    pulsePath.lineTo(size.width * 0.55, size.height * 0.7);
    pulsePath.lineTo(size.width * 0.6, size.height * 0.6);
    pulsePath.lineTo(size.width * 0.75, size.height * 0.6);

    canvas.drawPath(pulsePath, paint..strokeWidth = size.width * 0.06);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}