part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Assists with the mutations on [GENNPerceptron]s within the [GENNGeneService]
/// class.
class GennGeneServiceMutationHelper {
  GennGeneServiceMutationHelper({
    NumberGenerator? numberGenerator,
  }) : numberGenerator = numberGenerator ?? NumberGenerator();

  /// Used to generate random numbers and bools.
  final NumberGenerator numberGenerator;

  /// This function will mutate the given [perceptron] based on the input
  /// [selectedOption].
  ///
  /// Option 0 is bias.
  /// Option 1 is threshold.
  /// Any other int is one of the weights between perceptrons.
  @visibleForTesting
  GENNPerceptron mutateBasedOnSelectedOption(
    int selectedOption,
    GENNPerceptron perceptron,
  ) {
    switch (selectedOption) {
      case 0:
        // update bias
        return perceptron.copyWith(bias: numberGenerator.randomNegOneToPosOne);
      case 1:
        // update threshold
        return perceptron.copyWith(threshold: numberGenerator.nextDouble);

      default:
        // update weights
        final weights = List<double>.from(perceptron.weights);
        // Subtracting 2 to account for the bias and threshold options
        weights[selectedOption - 2] = numberGenerator.randomNegOneToPosOne;
        return perceptron.copyWith(weights: weights);
    }
  }

  /// Returns an [int] that represents the selected option to mutate within the
  /// given [perceptron].
  ///
  /// This number will be between 0 and (number of weights + 2)
  @visibleForTesting
  int selectMutationOption(GENNPerceptron perceptron) {
    var randValue = numberGenerator.nextDouble;

    // Represents how many options there are to choose from. It is the number of
    // weights plus the bias plus the threshold.
    final numOptions = (perceptron.weights.length + 2);

    // Represents the probability for each option to be selected
    final selectionProbabilty = 1.0 / numOptions.toDouble();

    // Represents which part of the perceptron was selected to mutate
    late int selectedOption;

    // Determine which part of the perceptron to mutate
    for (int i = 0; i < numOptions; i++) {
      randValue -= selectionProbabilty;
      if (randValue < 0) {
        selectedOption = i;
        break;
      }
    }
    return selectedOption;
  }
}
