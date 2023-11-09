part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class is responsible for mutating and creating random Genes.
class GENNGeneService extends GeneService<GENNPerceptron> {
  GENNGeneService({
    required this.numInitialInputs,
    Random? random,
  }) : random = random ?? Random();

  final Random random;

  final int numInitialInputs;
  // TODO: Investigate this being const or in-lined below OR should we be able
  /// to pass the value into randomGene() ?
  int initialLayer = 0;

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

  // TODO: Update this to have another internal call - one where it is
  /// selecting what thing to mutate, and another to actually mutate the value.
  /// That way the user could determine which of those they want to override.

  /// Mutates the given [GENNPerceptron].
  GENNPerceptron mutatePerceptron({
    required GENNPerceptron perceptron,
  }) {
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
        weights[selectedOption - 2] = randomNegOneToPosOne;
        return perceptron.copyWith(weights: weights);
    }
  }

  @override
  Gene<GENNPerceptron> randomGene() {
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
