import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:logical_xor/perceptron_map/consts.dart';

class WeightLinePainter extends CustomPainter {
  WeightLinePainter({
    required this.leftX,
    required this.leftY,
    required this.rightX,
    required this.rightY,
    required this.weight,
  });

  final double leftX;
  final double leftY;
  final double rightX;
  final double rightY;
  final double weight;

  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Offset(leftX, leftY);
    final p2 = Offset(rightX, rightY);

    final strokeWidth = clampDouble(
        maxBorderThickness * (weight.abs()), minThickness, maxBorderThickness);

    final color = weight.isNegative ? negativeColor : positiveColor;
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;
    canvas.drawLine(p1, p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
