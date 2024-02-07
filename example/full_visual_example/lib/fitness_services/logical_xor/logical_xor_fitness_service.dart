import 'dart:math';

import 'package:flutter/material.dart';
import 'package:full_visual_example/visualization_helpers/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This fitness service will be used to score a logical XOR calculator. The
/// output should only return true if a single value is 1.0 and both other
/// values are 0.0. There should be one exclusive positive value! The more
/// correct guesses that a NeuralNetwork makes, the higher its fitness score
/// will be.
class LogicalXORFitnessService extends GENNVisualizationExampleFitnessService<
    List<double>, LogicalXorOutput> {
// ================== START OF GENN EXAMPLE RELATED CONTENT =============================
// ================== GENNFitnessService Overrides ======================================

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
      final error = (targetOutputsList[i] == guesses[i]) ? 0 : 1;

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
// ================== END OF GENN EXAMPLE RELATED CONTENT ===============================

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
                (input) => input.toString(),
              )
              .join(', '),
        ),
      )
      .toList();

  @override
  List<LogicalXorOutput> targetOutputsList = [
    LogicalXorOutput.no,
    LogicalXorOutput.yes,
    LogicalXorOutput.yes,
    LogicalXorOutput.no,
    LogicalXorOutput.yes,
    LogicalXorOutput.no,
    LogicalXorOutput.no,
    LogicalXorOutput.no,
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
  String convertToReadableString(LogicalXorOutput value) {
    return value.name;
  }

  @override
  double? get highestPossibleScore => pow(4, 8).toDouble();

  @override
  int get numInitialInputs => 3;

  @override
  int get numOutputs => 1;

  @override
  LogicalXorOutput convertGuessToOutputType({
    required List<double> guess,
  }) {
    // There will always be 1 output to this neural network, so choose the first
    // item in the list.
    final value = guess[0];
    if (value == 0.0) {
      // Zero means we are sure it is not satisfied
      return LogicalXorOutput.no;
    } else if (value == 1.0) {
      // One means we are sure it is satisfied
      return LogicalXorOutput.yes;
    }
    // Anything in between means we are not sure it is not satisfied
    return LogicalXorOutput.unsure;
  }

  @override
  List<double> convertInputToNeuralNetworkInput({
    required List<double> input,
  }) {
    return input;
  }
}

enum LogicalXorOutput {
  yes,
  no,
  unsure,
}
