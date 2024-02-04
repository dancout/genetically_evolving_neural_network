import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class implements functions to help visualize the [GENN] class in
/// action.
///
/// The input and output types of the Neural Network can be represented by the
/// types <I, O>, respectively.
abstract class GENNVisualizationExample<I, O> {
  /// The list of inputs for your Neural Network.
  List<I> get inputList;

  /// The [GENNVisualizationExample.inputList] converted into a List of more
  /// human readable Widgets.
  List<Widget> get readableInputList;

  /// The list of outputs, or guesses, for your Neural Network. These are the
  /// expected outputs respective to the inputs from
  /// [GENNVisualizationExample.inputList].
  List<O> get targetOutputsList;

  // TODO: Could we make readableTargetList also a list of Widgets to be
  /// more flexible for future services?

  /// The [GENNVisualizationExample.targetOutputsList] converted into a List of
  /// more human readable Strings.
  List<String> get readableTargetList;

  /// The function used to convert a Neural Network output of Type <O> to be
  /// more human readable.
  String convertToReadableString(O value) {
    throw UnimplementedError();
  }

  /// The highest possible fitness score, or null if it is not known.
  double? get highestPossibleScore;

  /// The target fitness score to achieve, or null if it is not known.
  double? get targetFitnessScore;

  /// Returns the list of guesses (or outputs) from the input [neuralNetwork]
  /// based on [GENNVisualizationExample.inputList].
  List<O> getNeuralNetworkGuesses({
    required GENNNeuralNetwork neuralNetwork,
  });

  /// The number of inputs being fed into the Neural Network.
  int get numInitialInputs;

  /// The number of outputs expected from the Neural Network.
  int get numOutputs;
}
