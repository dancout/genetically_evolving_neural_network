import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:full_visual_example/perceptron_map/consts.dart';
import 'package:full_visual_example/perceptron_map/visualized_perceptron.dart';
import 'package:full_visual_example/perceptron_map/weight_line_painter.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class PerceptronMap extends StatelessWidget {
  const PerceptronMap({
    super.key,
    required this.entity,
    required this.numInputs,
    required this.numOutputs,
    this.showLabels = false,
  });

  final GENNEntity entity;
  final int numInputs;
  final int numOutputs;
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];

    // Add initial inputs as passthrough perceptrons with weights
    final inputPerceptrons = List.generate(
        numInputs,
        (index) => const GENNPerceptron(
            layer: 0, bias: 0, threshold: 1.0, weights: [1.0]));

    addWeightsLayer(
      perceptrons: inputPerceptrons,
      totalPerceptronSize: totalPerceptronSize,
      rows: rows,
      showLabels: showLabels,
    );

    // This represents the visualization of the input layer as perceptrons
    final visualizedPerceptron = VisualizedPerceptron(
      // We've given a border thickness so that they are aesthetically pleasing,
      // but it would be more accurate to put a threshold of 0 and a bias of 0
      // because we should respect all inputs for exactly the value they
      // represent.
      biasColor: positiveColor.withOpacity(0.1),
      borderThickness: maxBorderThickness,
    );
    rows.add(
      Column(
        children: List.generate(
          numInputs,
          (index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: extraSidePadding),
              child: visualizedPerceptron,
            );
          },
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
    rows.addAll(
      [
        Column(
          children: List.generate(
            numOutputs,
            (index) => CustomPaint(
              painter: WeightLinePainter(
                leftX: 0,
                leftY:
                    (index * totalPerceptronSize) + (totalPerceptronSize / 2),
                rightX: weightsColumnWidth,
                rightY:
                    (index * totalPerceptronSize) + (totalPerceptronSize / 2),
                weight: 1.0,
              ),
            ),
          ),
        ),
        Column(
          children: List.generate(
            numOutputs,
            (index) => const SizedBox(width: weightsColumnWidth),
          ),
        ),
        Column(
          children: List.generate(
            numOutputs,
            (index) => (showLabels)
                ? SizedBox(
                    height: totalPerceptronSize,
                    child: Text(
                      'output - ${index + 1}',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  )
                : const SizedBox(),
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
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
    bool showLabels = false,
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
      // This is for the input layer
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
      Row(
        children: [
          if (showLabels)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(
                numInputs,
                (index) {
                  String label = _generateLabel(index);
                  return SizedBox(
                    height: totalPerceptronSize,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  );
                },
              ),
            ),
          Stack(
            children: weightsChildren,
          ),
        ],
      ),
    );
  }

  String _generateLabel(int index) {
    const lowercaseAindex = 97;
    final numLettersToShow = (index / 26).floor() + 1;
    final asciiIndex = (index % 26) + lowercaseAindex;

    final letter = String.fromCharCode(asciiIndex);
    String label = '';
    for (int i = 0; i < numLettersToShow; i++) {
      label += letter;
    }
    return label;
  }
}
