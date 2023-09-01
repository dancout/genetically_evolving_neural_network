import 'package:genetic_evolution/genetic_evolution.dart';

class GENNGeneticEvolutionConfig extends GeneticEvolutionConfig {
  GENNGeneticEvolutionConfig({
    required this.numInitialInputs,
    required int numOutputs,
    required this.layerMutationRate,
    required this.perceptronMutationRate,
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
