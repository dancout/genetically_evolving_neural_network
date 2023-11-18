part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class is responsible for mutating and creating random Genes.
class GENNGeneService extends GeneService<GENNPerceptron> {
  GENNGeneService({
    required this.numInitialInputs,
    Random? random,
  }) : random = random ?? Random();

  /// Used for random number generation.
  final Random random;

  /// Represents the number of initial inputs for creating a Random Gene.
  final int numInitialInputs;

  /// Produces a random double between -1 and 1, exclusively.
  double get randomNegOneToPosOne => (random.nextDouble() * 2) - 1;

  /// Creates a randomized [GENNPerceptron].
  GENNPerceptron randomPerceptron({
    required int numWeights,
    required int layer,
  }) {
    assert(
      numWeights > 0,
      'numWeights must be greater than 0 when creating a random Perceptron.',
    );

    return GENNPerceptron(
      bias: randomNegOneToPosOne,
      threshold: random.nextDouble(),
      weights: List.generate(numWeights, (_) => randomNegOneToPosOne),
      layer: layer,
    );
  }

  /// Mutates the given [GENNPerceptron].
  GENNPerceptron mutatePerceptron({
    required GENNPerceptron perceptron,
  }) {
    // Select an option to mutate
    int selectedOption = selectMutationOption(perceptron);

    // Return a new GENNPerceptron with its selected mutation
    return mutateBasedOnSelectedOption(selectedOption, perceptron);
  }

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
        return perceptron.copyWith(bias: randomNegOneToPosOne);
      case 1:
        // update threshold
        return perceptron.copyWith(threshold: random.nextDouble());

      default:
        // update weights
        final weights = List<double>.from(perceptron.weights);
        // Subtracting 2 to account for the bias and threshold options
        weights[selectedOption - 2] = randomNegOneToPosOne;
        return perceptron.copyWith(weights: weights);
    }
  }

  /// Returns an [int] that represents the selected option to mutate within the
  /// given [perceptron].
  ///
  /// This number will be between 0 and (number of weights + 2)
  @visibleForTesting
  int selectMutationOption(GENNPerceptron perceptron) {
    var randValue = random.nextDouble();

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
      }
    }
    return selectedOption;
  }

  @override
  Gene<GENNPerceptron> randomGene() {
    const initialLayer = 0;

    return GENNGene(
      value: randomPerceptron(
        layer: initialLayer,
        numWeights: numInitialInputs,
      ),
    );
  }

  @override
  GENNPerceptron mutateValue({GENNPerceptron? value}) {
    final gennPerceptron = value;
    if (gennPerceptron == null) {
      throw Exception('Cannot mutate null GENNPerceptron.');
    }

    return mutatePerceptron(perceptron: gennPerceptron);
  }
}