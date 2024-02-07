import 'package:flutter/material.dart';
import 'package:full_visual_example/visualization_helpers/perceptron_map/consts.dart';

class VisualizedPerceptron extends StatelessWidget {
  const VisualizedPerceptron({
    super.key,
    required this.biasColor,
    required this.borderThickness,
  });

  final Color biasColor;
  final double borderThickness;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: circleDiameter,
      height: circleDiameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderThickness > 0
            ? Border.all(
                color: thresholdColor,
                width: borderThickness,
              )
            : null,
        color: biasColor,
      ),
    );
  }
}
