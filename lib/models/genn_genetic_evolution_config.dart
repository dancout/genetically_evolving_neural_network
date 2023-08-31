import 'package:genetic_evolution/genetic_evolution.dart';

class GENNGeneticEvolutionConfig extends GeneticEvolutionConfig {
  GENNGeneticEvolutionConfig({
    required this.initialNumWeights,
    required this.layerMutationRate,
    required this.perceptronMutationRate,
    required super.numGenes,
    required super.mutationRate,
    super.canReproduceWithSelf,
    super.numParents,
    super.populationSize,
    super.random,
    super.trackMutatedWaves,
    super.trackParents,
  });

  final int initialNumWeights;
  final double layerMutationRate;
  final double perceptronMutationRate;
}
