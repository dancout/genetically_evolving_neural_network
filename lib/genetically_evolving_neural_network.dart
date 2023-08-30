library genetically_evolving_neural_network;

import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_service.dart';

/// A Calculator.
class GeneticallyEvolvingNeuralNetwork {
  GeneticallyEvolvingNeuralNetwork({
    required this.fitnessService,
    required this.geneService,
    required this.config,
  });

  final GENNFitnessService fitnessService;
  final GENNGeneService geneService;
  final GeneticEvolutionConfig config;

  // TODO: Change from run
  Future<void> run() async {
    final generation = GeneticEvolution(
      geneticEvolutionConfig: config,
      fitnessService: fitnessService,
      geneService: geneService,
    );

    final nextGen = await generation.nextGeneration();
  }
}
