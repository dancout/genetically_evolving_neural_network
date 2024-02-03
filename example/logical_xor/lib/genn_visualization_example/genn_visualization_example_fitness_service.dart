import 'dart:math';

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

  /// This function will account for ties in guesses by randomly choosing an
  /// index of one of the guesses that tied for highest confidence. For example,
  /// if the guesses at index 4, 6, and 7 were all tied for the highest
  /// confidence score, each would have a 1/3 chance of being  as the "best
  /// guess".
  ///
  /// NOTE: This does introduce some volatility to the Neural Network, as an
  ///       Entity that has ties for a best guess may happen to guess correctly
  ///       in one run, but then guess incorrectly in the next run. So, your
  ///       Neural Network may reach the target score before all guesses become
  ///       completely consistent.
  int accountForGuessTies({
    required List<int> listOfHighestConfidenceIndices,
  }) {
    // Check if there was a tie on highest confidence
    if (listOfHighestConfidenceIndices.length > 1) {
      final randomDouble = Random().nextDouble();
      final chanceOfBeingPicked = 1.0 / listOfHighestConfidenceIndices.length;

      for (int x = 0; x < listOfHighestConfidenceIndices.length; x++) {
        if (randomDouble - (chanceOfBeingPicked * x) <= 0) {
          final pick = listOfHighestConfidenceIndices[x];

          listOfHighestConfidenceIndices.clear();
          listOfHighestConfidenceIndices.add(pick);
          break;
        }
      }
    }

    final highestConfidenceInt = listOfHighestConfidenceIndices[0];
    return highestConfidenceInt;
  }
}
