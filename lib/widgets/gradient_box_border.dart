import 'package:flutter/material.dart';

/// Custom gradient border for glassmorphism effect
/// Shared between habit cards
class GradientBoxBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBoxBorder({
    required this.gradient,
    this.width = 1.0,
  });

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  BorderSide get top => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final Paint paint = Paint()
      ..strokeWidth = width
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke;

    final Path path;
    if (borderRadius != null) {
      path = Path()..addRRect(borderRadius.toRRect(rect));
    } else {
      path = Path()..addRect(rect);
    }

    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return GradientBoxBorder(
      gradient: gradient,
      width: width * t,
    );
  }
}
