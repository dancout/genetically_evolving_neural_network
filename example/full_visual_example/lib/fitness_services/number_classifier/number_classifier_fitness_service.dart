import 'dart:math';

import 'package:full_visual_example/fitness_services/number_classifier/natural_number.dart';
import 'package:full_visual_example/fitness_services/number_classifier/number_classifier_fitness_service_helpers.dart';
import 'package:full_visual_example/visualization_helpers/genn_visualization_example/visualization_example_genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class will be used to score a Number Classifier in tandem with a
/// Neural Network.
class NumberClassifierFitnessService
    // NOTE: We are extending [GENNFitnessServiceVisualizationExample] instead
    //       of [GENNFitnessService] to include additional functions to assist
    //       with visualizing this example project.
    extends VisualizationExampleGENNFitnessService<PixelImage, NaturalNumber>
    // NOTE: This provides implementations of the above
    //       [GENNFitnessServiceVisualizationExample] class.
    with
        NumberClassifierFitnessServiceHelpers {
  /// Returns a score that proportional to how many correct guesses this Neural
  /// Network has made across all integers from 0 to 9.
  ///
  /// The scoring function is as follows:
  /// 4 ^ (correct number of guesses)
  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Collect all the guesses from this NeuralNetwork
    final guesses = getNeuralNetworkGuesses(neuralNetwork: neuralNetwork);

    // Declare a variable to store the sum of points scored
    int points = 0;

    // Cycle through each guess to check its validity
    for (int i = 0; i < guesses.length; i++) {
      final NaturalNumber targetOutput = targetOutputsList[i];
      final NaturalNumber guessOutput = guesses[i];

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
}
