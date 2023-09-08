library genetically_evolving_neural_network;

import 'package:flutter/foundation.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_genetic_evolution_config.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:genetically_evolving_neural_network/services/genn_dna_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_entity_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_mutation_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_service.dart';

/// A Calculator.
class GeneticallyEvolvingNeuralNetwork
    extends GeneticEvolution<GENNPerceptron> {
  /// This constructor is visibleForTesting because the [GENNDNAService] and
  /// [GENNGeneMutationService] are not intended to be exposed unless absolutely
  /// necessary.
  @visibleForTesting
  GeneticallyEvolvingNeuralNetwork({
    required super.fitnessService,
    required super.geneticEvolutionConfig,
    required super.geneService,
    super.entityService,
    super.populationService,
  });

  // final GENNGeneticEvolutionConfig config;

  factory GeneticallyEvolvingNeuralNetwork.create({
    required GENNGeneticEvolutionConfig config,
    required GENNFitnessService fitnessService,
    GENNGeneService? geneService,
    // TODO: Should this be visibleForTesting?
    GENNEntityService? entityService,
    // TODO: Should this be visibleForTesting?
    PopulationService<GENNPerceptron>? populationService,
  }) {
    final gennGeneService = geneService ??
        GENNGeneService(numInitialInputs: config.numInitialInputs);

    final geneMutationService = GENNGeneMutationService(
      trackMutatedWaves: config.trackMutatedWaves,
      mutationRate: config.mutationRate,
      gennGeneService: gennGeneService,
      random: config.random,
    );

    final dnaService = GENNDNAService(
      numGenes: config.numGenes,
      geneMutationService: geneMutationService,
    );

    final gennEntityService = entityService ??
        GENNEntityService(
          dnaService: dnaService,
          fitnessService: fitnessService,
          geneMutationService: geneMutationService,
          trackParents: config.trackParents,
          layerMutationRate: config.layerMutationRate,
          perceptronMutationRate: config.perceptronMutationRate,
          numOutputs: config.numGenes,
        );

    return GeneticallyEvolvingNeuralNetwork(
      fitnessService: fitnessService,
      geneticEvolutionConfig: config,
      geneService: gennGeneService,
      entityService: gennEntityService,
      populationService: populationService,
    );
  }
}
