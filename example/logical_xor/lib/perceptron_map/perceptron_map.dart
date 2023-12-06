import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/perceptron_map/consts.dart';
import 'package:logical_xor/perceptron_map/perceptron_map_key.dart';
import 'package:logical_xor/perceptron_map/visualized_perceptron.dart';
import 'package:logical_xor/perceptron_map/weight_line_painter.dart';

class PerceptronMap extends StatelessWidget {
  const PerceptronMap({
    super.key,
    required this.entity,
  });

  final GENNEntity entity;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    for (int layer = 0; layer < entity.maxLayerNum + 1; layer++) {
      final visualizedPerceptrons = <Widget>[];
      final genesInThisLayer =
          entity.dna.genes.where((gene) => gene.value.layer == layer);
      for (final gene in genesInThisLayer) {
        final threshold = gene.value.threshold;
        const maxBorderThickness = 8.0;
        final thresholdStrokeWidth = clampDouble(
            maxBorderThickness * (threshold.abs()),
            minThickness,
            maxBorderThickness);

        var bias = gene.value.bias;
        final biasOpacity = 1.0 - bias.abs();
        final biasColor = bias.isNegative ? negativeColor : positiveColor;

        visualizedPerceptrons.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: extraSidePadding),
            child: VisualizedPerceptron(
              biasColor: biasColor.withOpacity(biasOpacity),
              borderThickness: thresholdStrokeWidth,
            ),
          ),
        );
      }

      addWeightsLayer(
        perceptrons: genesInThisLayer.map((e) => e.value).toList(),
        totalPerceptronSize: totalPerceptronSize,
        rows: rows,
      );

      rows.add(
        Column(
          children: visualizedPerceptrons,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PerceptronMapKey(),
        const Text('Top Performing Perceptron'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...rows,
            // container
          ],
        ),
      ],
    );
  }

  void addWeightsLayer({
    required List<GENNPerceptron> perceptrons,
    required double totalPerceptronSize,
    required List<Widget> rows,
  }) {
    if (rows.isNotEmpty) {
      final prevColumn = rows.last as Column;

      final weightsChildren = <Widget>[];

      for (int perceptronIndex = 0;
          perceptronIndex < perceptrons.length;
          perceptronIndex++) {
        for (int weightIndex = 0;
            weightIndex < prevColumn.children.length;
            weightIndex++) {
          var container = Container(
            width: weightsColumnWidth,
            height: perceptrons.length * totalPerceptronSize,
            color: Colors.transparent,
            child: CustomPaint(
              painter: WeightLinePainter(
                  leftX: 0,
                  leftY: (weightIndex * totalPerceptronSize) +
                      (totalPerceptronSize / 2),
                  rightX: weightsColumnWidth,
                  rightY: (perceptronIndex * totalPerceptronSize) +
                      (totalPerceptronSize / 2),
                  weight: perceptrons[perceptronIndex].weights[weightIndex]),
            ),
          );
          weightsChildren.add(container);
        }
      }
      rows.add(
        Stack(
          children: weightsChildren,
        ),
      );
    }
  }
}
