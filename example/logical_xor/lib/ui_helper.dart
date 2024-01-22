import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/main.dart';
import 'package:logical_xor/perceptron_map/consts.dart';
import 'package:logical_xor/perceptron_map/perceptron_map.dart';

class UIHelper {
  const UIHelper({
    required this.numInitialInputs,
  });

  final int numInitialInputs;

  Widget showCorrectAnswers() {
    return Column(
      children: [
        const Text('Correct Answers'),
        const Text('   '),
        ...LogicalXORFitnessService()
            .targetOutputsList
            .map(
              (targetValue) => Text(
                targetValue[0].toString(),
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
        ...LogicalXORFitnessService()
            .logicalInputsList
            .map((e) => Text(e.toString()))
            .toList()
      ],
    );
  }

  Widget showGuesses(GENNEntity entity) {
    final logicalXORFitnessService = LogicalXORFitnessService();
    final guesses = logicalXORFitnessService.getGuesses(
      neuralNetwork: GENNNeuralNetwork.fromGenes(
        genes: entity.dna.genes,
      ),
    );

    final guessTextWidgets = [];

    for (int i = 0; i < guesses.length; i++) {
      final guess = guesses[i][0];
      final textWidget = Text(
        guess.toString(),
        style: (guess == logicalXORFitnessService.targetOutputsList[i][0])
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
