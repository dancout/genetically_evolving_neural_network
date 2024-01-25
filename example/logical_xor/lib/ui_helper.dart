import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:logical_xor/perceptron_map/consts.dart';
import 'package:logical_xor/perceptron_map/perceptron_map.dart';

class UIHelper {
  UIHelper({
    required this.numInitialInputs,
    required this.gennExampleFitnessService,
  });

  final int numInitialInputs;

  final perceptronMapDivider = Container(height: 4, color: Colors.grey);

  final GENNVisualizationExampleFitnessService gennExampleFitnessService;

  Widget showCorrectAnswers() {
    return Column(
      children: [
        const Text('Correct Answers'),
        const Text('   '),
        ...gennExampleFitnessService.readableTargetList
            .map(
              (targetValue) => Text(
                targetValue,
              ),
            )
            .toList()
      ],
    );
  }

  Widget showLogicalInputs() {
    return Column(
      children: [
        const Text('Logical Inputs'),
        const Text(
          'a, b, c',
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        ...gennExampleFitnessService.readableInputList
            .map((e) => Text(e))
            .toList()
      ],
    );
  }

  Widget showNeuralNetworkGuesses(GENNEntity entity) {
    final guesses = gennExampleFitnessService.getNeuralNetworkGuesses(
      neuralNetwork: GENNNeuralNetwork.fromGenes(
        genes: entity.dna.genes,
      ),
    );

    final guessTextWidgets = [];

    for (int i = 0; i < guesses.length; i++) {
      final guess = guesses[i];
      final textWidget = Text(
        gennExampleFitnessService.convertToReadableString(guess),
        style: listEquals(
          guess,
          gennExampleFitnessService.targetOutputsList[i],
        )
            ? null
            : const TextStyle(
                color: negativeColor,
                fontWeight: FontWeight.bold,
              ),
      );

      guessTextWidgets.add(textWidget);
    }
    return Column(
      children: [
        const Text('Guesses'),
        const Text('   '),
        ...guessTextWidgets,
      ],
    );
  }

  Widget showPerceptronMapWithScore({
    required GENNEntity entity,
    bool showLabels = false,
  }) {
    const textWidth = 150.0;

    final veritcalDivider = Container(
      height: 48.0,
      width: circleDiameter,
      color: Colors.grey,
    );
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: weightsColumnWidth + 9 + circleDiameter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inputs',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              veritcalDivider,
            ],
          ),
        ),
        const Spacer(),
        const Text(
          'BRAIN',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        SizedBox(
          width: weightsColumnWidth + 53,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              veritcalDivider,
              const Text(
                'Output',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12.0),
            ],
          ),
        ),
      ],
    );
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabels) row,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              PerceptronMap(
                entity: GENNEntity.fromEntity(
                  entity: entity,
                ),
                numInputs: numInitialInputs,
                showLabels: showLabels,
              ),
              if (!showLabels)
                SizedBox(
                  width: textWidth,
                  child: Text(
                    'Score: ${entity.fitnessScore.toString()}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          if (showLabels)
            SizedBox(
              width: textWidth,
              child: Text(
                'Score: ${entity.fitnessScore.toString()}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }
}
