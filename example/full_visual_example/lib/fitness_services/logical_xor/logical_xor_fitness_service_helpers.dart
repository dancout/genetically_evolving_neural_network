import 'dart:math';

import 'package:flutter/material.dart';
import 'package:full_visual_example/fitness_services/logical_xor/logical_xor_output.dart';
import 'package:full_visual_example/visualization_helpers/genn_visualization_example/visualization_example_genn_fitness_service.dart';

/// Responsible for implementing the functions described in
/// [VisualizationExampleGENNFitnessService] with respect to the Logical XOR
/// example.
mixin LogicalXORFitnessServiceHelpers
    on VisualizationExampleGENNFitnessService<List<double>, LogicalXorOutput> {
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
