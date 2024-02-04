import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example_fitness_service.dart';

/// This fitness service will be used to score a logical XOR calculator. The
/// output should only return true if a single value is 1.0 and both other
/// values are 0.0. There should be one exclusive positive value! The more
/// correct guesses that a NeuralNetwork makes, the higher its fitness score
/// will be.
class LogicalXORFitnessService
    extends GENNVisualizationExampleFitnessService<List<double>, double> {
// ================== GENNFitnessService Overrides ========================

  // TODO: Could change the output type of this class to be an enum of False,
  /// Unsure, True. Then instead of comparing 1 vs 1, it'd be true vs true.

  /// This function will calculate a fitness score after guessing with every
  /// input within [LogicalXORFitnessService.inputList] on the input
  /// [neuralNetwork].
  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Collect all the guesses from this NeuralNetwork
    final guesses = getNeuralNetworkGuesses(neuralNetwork: neuralNetwork);

    // Declare a variable to store the sum of all errors
    var errorSum = 0.0;

    // Cycle through each guess to check its validity
    for (int i = 0; i < guesses.length; i++) {
      // Calculate the error from this guess
      final error = (targetOutputsList[i] - guesses[i]).abs();

      // Add this error to the errorSum
      errorSum += error;
    }

    // Calculate the difference between a perfect score (8) and the total
    // errors. A perfect score would mean zero errors with 8 correct answers,
    // meaning a perfect score would be 8.
    final diff = inputList.length - errorSum;

    // To make the better performing Entities stand out more in this population,
    // use the following equation to calculate the FitnessScore.
    //
    // 4 to the power of diff
    return pow(4, diff).toDouble();
  }

  // ================== GENNVisualizationExample Overrides ===================
  @override
  List<List<double>> inputList = [
    [0.0, 0.0, 0.0],
    [0.0, 0.0, 1.0],
    [0.0, 1.0, 0.0],
    [0.0, 1.0, 1.0],
    [1.0, 0.0, 0.0],
    [1.0, 0.0, 1.0],
    [1.0, 1.0, 0.0],
    [1.0, 1.0, 1.0],
  ];

  @override
  List<Widget> get readableInputList => inputList
      .map(
        (inputs) => Text(
          inputs
              .map(
                (input) => convertToReadableString(input),
              )
              .join(', '),
        ),
      )
      .toList();

  @override
  List<double> targetOutputsList = [
    0.0,
    1.0,
    1.0,
    0.0,
    1.0,
    0.0,
    0.0,
    0.0,
  ];

  @override
  List<Widget> get readableTargetList => targetOutputsList
      .map(
        (targetOutput) => Text(
          convertToReadableString(targetOutput),
        ),
      )
      .toList();

  @override
  String convertToReadableString(double value) {
    return value.toString();
  }

  @override
  double? get highestPossibleScore => pow(4, 8).toDouble();

  @override
  int get numInitialInputs => 3;

  @override
  int get numOutputs => 1;

  @override
  double convertGuessToOutputType({
    required List<double> guess,
  }) {
    // There will always be 1 output to this neural network, so return the first
    // item in the list.
    return guess[0];
  }

  @override
  List<double> convertInputToNeuralNetworkInput({
    required List<double> input,
  }) {
    return input;
  }
}
