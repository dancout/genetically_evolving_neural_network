part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNGeneticEvolutionConfig extends GeneticEvolutionConfig {
  GENNGeneticEvolutionConfig({
    required this.numInitialInputs,
    required int numOutputs,
    required this.layerMutationRate,
    required this.perceptronMutationRate,

    /// The rate at which individual Perceptrons will mutate during crossover.
    required super.mutationRate,
    super.canReproduceWithSelf,
    super.numParents,
    super.populationSize,
    super.random,
    super.trackMutatedWaves,
    super.trackParents,
    super.generationsToTrack,
  }) : super(numGenes: numOutputs);

  /// Represents the number of initial inputs for creating a Random Gene.
  final int numInitialInputs;

  /// The rate at which a PerceptronLayer will be added or removed from an
  /// Entity.
  final double layerMutationRate;

  /// The rate at which a Perceptron will be added or removed from a given
  /// PerceptronLayer.
  final double perceptronMutationRate;
}
