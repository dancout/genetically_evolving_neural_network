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
    required this.numInputs,
  });

  final GENNEntity entity;
  final int numInputs;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    // Add initial inputs as passthrough perceptrons with weights
    final inputPerceptrons = List.generate(
        numInputs,
        (index) =>
            GENNPerceptron(layer: 0, bias: 0, threshold: 1.0, weights: [1.0]));

    addWeightsLayer(
      perceptrons: inputPerceptrons,
      totalPerceptronSize: totalPerceptronSize,
      rows: rows,
    );

    rows.add(
      Column(
        children: List.generate(
          numInputs,
          (index) => const Padding(
            padding: EdgeInsets.symmetric(vertical: extraSidePadding),
            child: VisualizedPerceptron(
              biasColor: Colors.transparent,
              borderThickness: maxBorderThickness,
            ),
          ),
        ),
      ),
    );

    // Add perceptrons from entity
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

    // Add final output passthrough weight
    rows.add(
      CustomPaint(
        painter: WeightLinePainter(
          leftX: 0,
          leftY: (totalPerceptronSize / 2),
          rightX: weightsColumnWidth,
          rightY: (totalPerceptronSize / 2),
          weight: 1.0,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PerceptronMapKey(),
        const Text('Top Performing Neural Network'),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows,
        ),
      ],
    );
  }

  void addWeightsLayer({
    required List<GENNPerceptron> perceptrons,
    required double totalPerceptronSize,
    required List<Widget> rows,
  }) {
    final weightsChildren = <Widget>[];

    if (rows.length > 1) {
      final prevColumn = rows.last as Column;

      for (int perceptronIndex = 0;
          perceptronIndex < perceptrons.length;
          perceptronIndex++) {
        for (int weightIndex = 0;
            weightIndex < prevColumn.children.length;
            weightIndex++) {
          var weightLayer = Container(
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
                weight: perceptrons[perceptronIndex].weights[weightIndex],
              ),
            ),
          );
          weightsChildren.add(weightLayer);
        }
      }
    } else {
      for (int perceptronIndex = 0;
          perceptronIndex < perceptrons.length;
          perceptronIndex++) {
        var weightLayer = Container(
          width: weightsColumnWidth,
          height: perceptrons.length * totalPerceptronSize,
          color: Colors.transparent,
          child: CustomPaint(
            painter: WeightLinePainter(
              leftX: 0,
              leftY: (perceptronIndex * totalPerceptronSize) +
                  (totalPerceptronSize / 2),
              rightX: weightsColumnWidth,
              rightY: (perceptronIndex * totalPerceptronSize) +
                  (totalPerceptronSize / 2),
              weight: perceptrons[perceptronIndex].weights[0],
            ),
          ),
        );
        weightsChildren.add(weightLayer);
      }
    }
    rows.add(
      Stack(
        children: weightsChildren,
      ),
    );
  }
}
