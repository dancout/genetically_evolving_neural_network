import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class implements functions to help visualize the [GENN] class in
/// action.
abstract class GENNVisualizationExample<T> {
  /// The list of inputs for your Neural Network. The values can range from
  /// -1 to 1.
  // TODO: If I really wanted to, I could make the input list be a type <I> and
  /// then specify that to be slightly more readable, too. As in, the input is a
  /// King of spades (if we're doing a card game), instead of a list of doubles
  List<List<double>> get inputsList;

  /// The [GENNVisualizationExample.inputsList] converted into a List of more
  /// human readable Widgets.
  List<Widget> get readableInputList;

  /// The list of outputs, or guesses, for your Neural Network. These are the
  /// expected outputs respective to the inputs.
  List<T> get targetOutputsList;

  /// The [GENNVisualizationExample.targetOutputsList] converted into a List of
  /// more human readable Strings.
  List<String> get readableTargetList;

  /// The function used to convert a Neural Network output of Type <T> to be
  /// more human readable.
  String convertToReadableString(T value) {
    throw UnimplementedError();
  }

  /// The highest possible fitness score, or null if it is not known.
  double? get highestPossibleScore;

  /// The target fitness score to achieve, or null if it is not known.
  double? get targetFitnessScore;

  /// Returns the list of guesses (or outputs) from the input [neuralNetwork]
  /// based on [GENNVisualizationExample.inputsList].
  List<T> getNeuralNetworkGuesses({
    required GENNNeuralNetwork neuralNetwork,
  });

  /// The number of inputs being fed into the Neural Network.
  int get numInitialInputs;

  /// The number of outputs expected from the Neural Network.
  int get numOutputs;
}
