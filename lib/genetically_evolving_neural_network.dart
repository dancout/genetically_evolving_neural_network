library genetically_evolving_neural_network;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

part 'package:genetically_evolving_neural_network/models/genn_dna.dart';
part 'package:genetically_evolving_neural_network/models/genn_entity.dart';
part 'package:genetically_evolving_neural_network/models/genn_gene.dart';
part 'package:genetically_evolving_neural_network/models/genn_genetic_evolution_config.dart';
part 'package:genetically_evolving_neural_network/models/genn_neural_network.dart';
part 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
part 'package:genetically_evolving_neural_network/models/genn_perceptron_layer.dart';
part 'package:genetically_evolving_neural_network/services/genn_crossover_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_dna_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_entity_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_mutation_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_service.dart';
part 'package:genetically_evolving_neural_network/services/perceptron_layer_mutation_service.dart';

/// A Calculator.
// TODO: Would it be better to call this class "GENN"?
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
    // TODO: Should this be visibleForTesting?
    GENNGeneService? geneService,
    @visibleForTesting GENNEntityService? entityService,
    @visibleForTesting PopulationService<GENNPerceptron>? populationService,
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

    final crossoverService = GENNCrossoverService(
      perceptronLayerMutationService: PerceptronLayerMutationService(
        fitnessService: fitnessService,
        geneService: geneMutationService.gennGeneService,
      ),
      geneMutationService: geneMutationService,
      numOutputs: config.numGenes,
    );

    final gennEntityService = entityService ??
        GENNEntityService(
          dnaService: dnaService,
          fitnessService: fitnessService,
          geneMutationService: geneMutationService,
          trackParents: config.trackParents,
          layerMutationRate: config.layerMutationRate,
          perceptronMutationRate: config.perceptronMutationRate,
          crossoverService: crossoverService,
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
