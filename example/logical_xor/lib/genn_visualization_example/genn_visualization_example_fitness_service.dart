import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example.dart';

/// Represents a wrapper class that extends [GENNFitnessService] and implements
/// [GENNVisualizationExample].
///
/// The input and output types of the Neural Network can be represented by the
/// types <I, O> respectively.
abstract class GENNVisualizationExampleFitnessService<I, O>
    extends GENNFitnessService implements GENNVisualizationExample<I, O> {
  @override
  Future<double> gennScoringFunction(
      {required GENNNeuralNetwork neuralNetwork});

  @override
  List<O> getNeuralNetworkGuesses({
    required GENNNeuralNetwork neuralNetwork,
  }) {
    // Declare a list of guesses
    List<O> guesses = [];

    // Cycle through each input
    for (int i = 0; i < inputList.length; i++) {
      // Declare this run's set of inputs
      final input = inputList[i];

      // Convert this class's Input type into a List of doubles to be fed into
      // the Neural Network.
      final logicalInputs = convertInputToNeuralNetworkInput(
        input: input,
      );

      // Make a guess using the NeuralNetwork
      final guess = neuralNetwork.guess(
        inputs: logicalInputs,
      );

      // Add this guess to the list of guesses
      guesses.add(
        convertGuessToOutputType(
          guess: guess,
        ),
      );
    }

    // Return the list of guesses
    return guesses;
  }

  /// Converts the input [guess] (which is expected to the be output from a
  /// Nueral Network) into the expected Output Type <O> from this class.
  O convertGuessToOutputType({
    required List<double> guess,
  });

  /// Converts this class's Input type <I> into a List<double> that can be fed
  /// into the Neural Network.
  List<double> convertInputToNeuralNetworkInput({
    required I input,
  });

  @override
  double? get highestPossibleScore;

  @override
  List<I> get inputList;

  @override
  List<Widget> get readableInputList;

  @override
  List<Widget> get readableTargetList;

  @override
  double? get targetFitnessScore => (highestPossibleScore != null)
      ? (highestPossibleScore! + nonZeroBias)
      : null;

  @override
  List<O> get targetOutputsList;

  @override
  String convertToReadableString(O value);

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
