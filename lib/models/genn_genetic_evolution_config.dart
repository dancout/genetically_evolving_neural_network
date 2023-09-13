part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNGeneticEvolutionConfig extends GeneticEvolutionConfig {
  GENNGeneticEvolutionConfig({
    required this.numInitialInputs,
    required int numOutputs,

    /// The rate at which a PerceptronLayer will be added or removed from an
    /// Entity.
    required this.layerMutationRate,

    /// The rate at which a Perceptron will be added or removed from a given
    /// PerceptronLayer.
    required this.perceptronMutationRate,

    /// The rate at which individual Perceptrons will mutate during crossover.
    required super.mutationRate,
    super.canReproduceWithSelf,
    super.numParents,
    super.populationSize,
    super.random,
    super.trackMutatedWaves,
    super.trackParents,
  }) : super(numGenes: numOutputs);

  final int numInitialInputs;
  final double layerMutationRate;
  final double perceptronMutationRate;
}
