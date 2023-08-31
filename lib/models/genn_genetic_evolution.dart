import 'package:flutter/foundation.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_genetic_evolution_config.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:genetically_evolving_neural_network/services/genn_dna_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_entity_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_mutation_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_service.dart';

class GENNGeneticEvolution extends GeneticEvolution<GENNPerceptron> {
  /// This constructor is visibleForTesting because the [GENNDNAService] and
  /// [GENNGeneMutationService] are not intended to be exposed unless absolutely
  /// necessary.
  @visibleForTesting
  GENNGeneticEvolution({
    required super.geneticEvolutionConfig,
    required super.fitnessService,
    required super.geneService,
    super.populationService,
    super.entityService,
  });

  factory GENNGeneticEvolution.create({
    required GENNGeneticEvolutionConfig config,
    required GENNFitnessService fitnessService,
    required GENNGeneService geneService,
    // TODO: Should this be visibleForTesting?
    GENNEntityService? entityService,
    PopulationService<GENNPerceptron>? populationService,
  }) {
    final geneMutationService = GENNGeneMutationService(
      trackMutatedWaves: config.trackMutatedWaves,
      mutationRate: config.mutationRate,
      geneService: geneService,
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
        );

    return GENNGeneticEvolution(
      geneticEvolutionConfig: config,
      fitnessService: fitnessService,
      geneService: geneService,
      entityService: gennEntityService,
      populationService: populationService,
    );
  }
}
