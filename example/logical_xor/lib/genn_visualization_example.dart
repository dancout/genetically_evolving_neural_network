import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class implements functions to help visualize the [GENN] class in
/// action.
abstract class GENNVisualizationExample {
  /// The list of inputs for your Neural Network. The values can range from
  /// -1 to 1.
  List<List<double>> get inputsList;

  /// The [GENNVisualizationExample.inputsList] converted into a List of more
  /// human readable Strings.
  List<String> get readableInputList;

  /// The list of outputs, or guesses, for your Neural Network. These are the
  /// expected outputs respective to the logical inputs.
  List<List<double>> get targetOutputsList;

  /// The [GENNVisualizationExample.targetOutputsList] converted into a List of
  /// more human readable Strings.
  List<String> get readableTargetList;

  /// The function used to convert a List of values (whether inputs or outputs)
  /// to be more human readable.
  static String convertToReadableString(List<double> valueList) {
    throw UnimplementedError();
  }

  /// The highest possible fitness score, or null if it is not known.
  double? get highestPossibleScore;

  /// The target fitness score to achieve, or null if it is not known.
  double? get targetFitnessScore;

  /// Returns the list of guesses (or outputs) from the input [neuralNetwork]
  /// based on [GENNVisualizationExample.inputsList].
  List<List<double>> getNeuralNetworkGuesses({
    required GENNNeuralNetwork neuralNetwork,
  });
}
