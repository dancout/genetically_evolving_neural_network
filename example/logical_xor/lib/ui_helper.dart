import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:logical_xor/perceptron_map/consts.dart';
import 'package:logical_xor/perceptron_map/perceptron_map.dart';

/// Responsible for showing various parts of the Example UI that aren't related
/// to how the Genetically Evolving Neural Network works.
class UIHelper<I, O> {
  UIHelper({
    required this.gennExampleFitnessService,
  });

  final perceptronMapDivider = Container(height: 4, color: Colors.grey);

  final GENNVisualizationExampleFitnessService<I, O> gennExampleFitnessService;

  Widget showCorrectAnswers() {
    return Column(
      children: [
        const Text('Correct Answers'),
        const Text('   '),
        ...gennExampleFitnessService.readableTargetList
      ],
    );
  }

  Widget showLogicalInputs() {
    return Column(
      children: [
        const Text('Logical Inputs'),
        const Text(
          'a, b, c...',
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        ...gennExampleFitnessService.readableInputList
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
      final readableGuess =
          gennExampleFitnessService.convertToReadableString(guess);
      final readableTarget = gennExampleFitnessService.convertToReadableString(
        gennExampleFitnessService.targetOutputsList[i],
      );
      final textWidget = Text(
        readableGuess,
        style: readableGuess == readableTarget
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
    final veritcalDivider = Container(
      height: 48.0,
      width: circleDiameter,
      color: Colors.grey,
    );
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: weightsColumnWidth + 13 + circleDiameter,
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
          width: weightsColumnWidth + 84,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              veritcalDivider,
              const Text(
                'Output(s)',
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
          SizedBox(
            child: Text(
              'Score: ${entity.fitnessScore.toString()}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showLabels) row,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              PerceptronMap(
                entity: GENNEntity.fromEntity(
                  entity: entity,
                ),
                numInputs: gennExampleFitnessService.numInitialInputs,
                numOutputs: gennExampleFitnessService.numOutputs,
                showLabels: showLabels,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
