import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Sello de verificación: anillos, marcas radiales y un visto bueno al centro.
class SealMark extends StatelessWidget {
  const SealMark({
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 2,
  });

  final double size;
  final Color color;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(painter: _SealPainter(color, strokeWidth)),
      ),
    );
  }
}

class _SealPainter extends CustomPainter {
  _SealPainter(this.color, this.strokeWidth);

  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - strokeWidth;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(center, radius * 0.72, paint);

    // Marcas entre los dos anillos.
    const ticks = 36;
    for (var i = 0; i < ticks; i++) {
      final angle = 2 * math.pi * i / ticks;
      final direction = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(
        center + direction * (radius * 0.80),
        center + direction * (radius * 0.92),
        paint,
      );
    }

    // Visto bueno al centro.
    final check = Path()
      ..moveTo(center.dx - radius * 0.25, center.dy)
      ..lineTo(center.dx - radius * 0.06, center.dy + radius * 0.20)
      ..lineTo(center.dx + radius * 0.28, center.dy - radius * 0.20);
    canvas.drawPath(check, paint..strokeWidth = strokeWidth * 1.4);
  }

  @override
  bool shouldRepaint(_SealPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}