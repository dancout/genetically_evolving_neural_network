import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example.dart';

/// Represents a wrapper class that extends [GENNFitnessService] and implements
/// [GENNVisualizationExample].
abstract class GENNVisualizationExampleFitnessService extends GENNFitnessService
    implements GENNVisualizationExample {
  @override
  Future<double> gennScoringFunction(
      {required GENNNeuralNetwork neuralNetwork});

  @override
  List<List<double>> getNeuralNetworkGuesses({
    required GENNNeuralNetwork neuralNetwork,
  }) {
    // Declare a list of guesses
    List<List<double>> guesses = [];

    // Cycle through each input
    for (int i = 0; i < inputsList.length; i++) {
      // Declare this run's set of inputs
      final inputs = inputsList[i];

      // Make a guess using the NeuralNetwork
      final guess = neuralNetwork.guess(inputs: inputs);

      // Add this guess to the list of guesses
      guesses.add(guess);
    }

    // Return the list of guesses
    return guesses;
  }

  @override
  double? get highestPossibleScore;

  @override
  List<List<double>> get inputsList;

  @override
  List<Widget> get readableInputList;

  @override
  List<String> get readableTargetList;

  @override
  double? get targetFitnessScore => (highestPossibleScore != null)
      ? (highestPossibleScore! + nonZeroBias)
      : null;

  @override
  List<List<double>> get targetOutputsList;

  @override
  String convertToReadableString(List<double> valueList);
}
