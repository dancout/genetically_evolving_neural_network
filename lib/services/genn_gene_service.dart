import 'dart:math';

import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

class GENNGeneService extends GeneService<GENNPerceptron> {
  GENNGeneService({
    required this.initialNumWeights,
    Random? random,
  }) : random = random ?? Random();

  final Random random;

  final int initialNumWeights;
  int initialLayer = 0;

  /// Produces a random double between -1 and 1, exclusively.
  double get randomNegOneToPosOne => (random.nextDouble() * 2) - 1;

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
      weights: List.generate(numWeights, (index) => randomNegOneToPosOne),
      layer: layer,
    );
  }

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
    return Gene(
      value: randomPerceptron(
        layer: initialLayer,
        numWeights: initialNumWeights,
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
