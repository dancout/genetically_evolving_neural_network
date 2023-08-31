import 'dart:math';

import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

abstract class GENNGeneService extends GeneService<GENNPerceptron> {
  GENNGeneService({
    required this.initialNumWeights,
    Random? random,
  }) : random = random ?? Random();

  final Random random;

  final int initialNumWeights;
  int initialLayer = 0;

  @override
  Gene<GENNPerceptron> randomGene() {
    return Gene(
      value: randomPerceptron(
        layer: initialLayer,
        numWeights: initialNumWeights,
      ),
    );
  }

  double randomNegOneToPosOne() => (random.nextDouble() * 2) - 1;

  GENNPerceptron randomPerceptron({
    required int numWeights,
    required int layer,
  }) {
    assert(
      numWeights > 0,
      'numWeights must be initialized before generating a random Perceptron.',
    );

    return GENNPerceptron(
      // TODO: Should bias be allowed to be negative?
      bias: random.nextDouble(),
      threshold: random.nextDouble(),
      weights: List.generate(numWeights, (index) => randomNegOneToPosOne()),
      layer: layer,
    );
  }

  GENNPerceptron mutatePerceptron({required GENNPerceptron perceptron});

  @override
  GENNPerceptron mutateValue({GENNPerceptron? value}) {
    final gennPerceptron = value;
    if (gennPerceptron == null) {
      // TODO: Investigate NN dependency - should value be able to be null ever?
      throw Exception('Cannot mutate null GENNPerceptron.');
    }

    return mutatePerceptron(perceptron: gennPerceptron);
  }
}
