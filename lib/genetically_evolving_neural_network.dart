library genetically_evolving_neural_network;

import 'package:genetically_evolving_neural_network/models/genn_genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_genetic_evolution_config.dart';
import 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_service.dart';

/// A Calculator.
class GeneticallyEvolvingNeuralNetwork {
  GeneticallyEvolvingNeuralNetwork({
    required this.fitnessService,
    required this.config,
    GENNGeneService? geneService,
  }) : geneService = geneService ??
            GENNGeneService(numInitialInputs: config.numInitialInputs);

  final GENNFitnessService fitnessService;
  final GENNGeneticEvolutionConfig config;
  final GENNGeneService geneService;

  // TODO: Change from run
  Future<void> run() async {
    final gennGeneticEvolution = GENNGeneticEvolution.create(
      config: config,
      fitnessService: fitnessService,
      geneService: geneService,
    );

    final nextGen = await gennGeneticEvolution.nextGeneration();
    print(nextGen.wave);
  }
}
