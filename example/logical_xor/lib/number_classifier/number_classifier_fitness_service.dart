import 'dart:math';

import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:logical_xor/number_classifier/natural_number.dart';

// TODO: could we make this class typed (like NumberClassifierFitnessService<T>)
/// so that we can convert an input list of List<T>, and then we can use
/// NaturalNum directly?
class NumberClassifierFitnessService
    extends GENNVisualizationExampleFitnessService {
  @override
  String convertToReadableString(List<double> valueList) {
    return determineBestGuess(guess: valueList).name;
  }

  // TODO: Documentation of this file?
  @override
  Future<double> gennScoringFunction(
      {required GENNNeuralNetwork neuralNetwork}) async {
    // Collect all the guesses from this NeuralNetwork
    final guesses = getNeuralNetworkGuesses(neuralNetwork: neuralNetwork);

    // Declare a variable to store the sum of points scored
    int points = 0;

    // Cycle through each guess to check its validity
    for (int i = 0; i < guesses.length; i++) {
      final NaturalNumber targetOutput =
          determineBestGuess(guess: targetOutputsList[i]);

      final NaturalNumber guessOutput = determineBestGuess(guess: guesses[i]);

      if (targetOutput == guessOutput) {
        // Guessing correctly will give you a point.
        points++;
      }
    }

    // To make the better performing Entities stand out more in this population,
    // use the following equation to calculate the FitnessScore.
    //
    // 4 to the power of points
    return pow(4, points).toDouble();
  }

  @override
  double? get highestPossibleScore => pow(4, 10).toDouble();

  @override
  List<List<double>> get inputsList =>
      NaturalNumber.values.map((e) => e.asPixels()).toList();

  @override
  List<String> get readableInputList {
    return NaturalNumber.values.map((e) => e.name).toList();
  }

  @override
  List<String> get readableTargetList => targetOutputsList
      .map((targetOutput) => convertToReadableString(targetOutput))
      .toList();

  @override
  List<List<double>> get targetOutputsList =>
      // Convert each NaturalNumber to its "correctGuess" form
      NaturalNumber.values
          .map((naturalNum) => naturalNum.asCorrectGuess)
          .toList();

  /// Returns the index of the guess with the highest confidence.
  // TODO: Should this go in a separate class, or the enum extension?
  NaturalNumber determineBestGuess({required List<double> guess}) {
    int index = 0;
    double confidence = 0;
    for (int i = 0; i < guess.length; i++) {
      // TODO: What to do about ties? We could add them all to a list and
      /// randomly pick one?

      if (guess[i] > confidence) {
        // If the current guess has a higher confidence, set it accordingly
        confidence = guess[i];
        index = i;
      }
    }
    return NaturalNumberExtension.parse(number: index);
  }
}
