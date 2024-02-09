import 'dart:math';

import 'package:full_visual_example/fitness_services/logical_xor/logical_xor_fitness_service_helpers.dart';
import 'package:full_visual_example/fitness_services/logical_xor/logical_xor_output.dart';
import 'package:full_visual_example/visualization_helpers/genn_visualization_example/visualization_example_genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This fitness service will be used to score a logical XOR calculator. The
/// Neural Network should only be rewarded for guessing "yes" when there is a
/// single input of 1.0 and both other inputs are 0.
class LogicalXORGENNVisualizationFitnessService extends
    // NOTE: We are extending [GENNFitnessServiceVisualizationExample] instead
    //       of [GENNFitnessService] to include additional functions to assist
    //       with visualizing this example project.
    VisualizationExampleGENNFitnessService<List<double>, LogicalXorOutput>
    // NOTE: This provides implementations of the above
    //       [GENNFitnessServiceVisualizationExample] class.
    with
        LogicalXORFitnessServiceHelpers {
  /// This function will calculate a fitness score after guessing with every
  /// input within [LogicalXORGENNVisualizationFitnessService.inputList] on the input
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
}
