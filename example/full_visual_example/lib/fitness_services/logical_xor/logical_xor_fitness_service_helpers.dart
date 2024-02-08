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

  @override
  String get diagramKeyTitle => 'Logical XOR Description';

  @override
  String get diagramKeyDescription =>
      'This Neural Network is meant to "guess" the output of the classic Logical Exclusive OR (XOR) problem.\n'
      'Given three inputs, it should output a 1 if ONLY a single input is 1. In any other case, output a 0 (see table to the right for all Correct Answers).\n\n'
      'Each new generation will choose high scoring parents from the previous generation to "breed" together and create new "children", so that the children\'s DNA is a mixture of both parents\' DNA.\n'
      'Additionally, the genes have a potential to "mutate", similar to mutations of animals in the real world.';
}
