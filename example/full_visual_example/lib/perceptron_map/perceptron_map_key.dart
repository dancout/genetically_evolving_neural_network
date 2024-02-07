import 'package:flutter/material.dart';
import 'package:full_visual_example/perceptron_map/consts.dart';
import 'package:full_visual_example/perceptron_map/visualized_perceptron.dart';
import 'package:full_visual_example/perceptron_map/weight_line_painter.dart';

class PerceptronMapKey extends StatelessWidget {
  const PerceptronMapKey({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    const innerSpasce = 12.0;

    return Column(
      children: [
        const SizedBox(height: 12.0),
        const Text(
          'DIAGRAM KEY',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('bias of +1'),
            VisualizedPerceptron(
              biasColor: positiveColor.withOpacity(1),
              borderThickness: 0,
            ),
            const SizedBox(width: innerSpasce),
            const Text('bias of +0.1'),
            VisualizedPerceptron(
              biasColor: positiveColor.withOpacity(0.1),
              borderThickness: 0,
            ),
            const SizedBox(width: innerSpasce),
            const Text('bias of -0.1'),
            VisualizedPerceptron(
              biasColor: negativeColor.withOpacity(0.1),
              borderThickness: 0,
            ),
            const SizedBox(width: innerSpasce),
            const Text('bias of -1'),
            VisualizedPerceptron(
              biasColor: negativeColor.withOpacity(1),
              borderThickness: 0,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('weight of +1'),
            getWeightPreview(weight: 1.0),
            const SizedBox(width: innerSpasce + weightsColumnWidth),
            const Text('weight of +0.1'),
            getWeightPreview(weight: 0.1),
            const SizedBox(width: innerSpasce + weightsColumnWidth),
            const Text('weight of -0.1'),
            getWeightPreview(weight: -0.1),
            const SizedBox(width: innerSpasce + weightsColumnWidth),
            const Text('weight of -1.0'),
            getWeightPreview(weight: -1.0),
          ],
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('activation threshold of +1'),
            VisualizedPerceptron(
              biasColor: Colors.transparent,
              borderThickness: maxBorderThickness,
            ),
            SizedBox(width: innerSpasce),
            Text('activation threshold of +0.1'),
            VisualizedPerceptron(
              biasColor: Colors.transparent,
              borderThickness: 0.1,
            ),
          ],
        ),
      ],
    );
  }

  CustomPaint getWeightPreview({
    required double weight,
  }) {
    return CustomPaint(
      painter: WeightLinePainter(
        leftX: 0,
        leftY: 0,
        rightX: weightsColumnWidth,
        rightY: 0,
        weight: weight,
      ),
    );
  }
}
