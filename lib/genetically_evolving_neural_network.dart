library genetically_evolving_neural_network;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

part 'package:genetically_evolving_neural_network/models/genn_dna.dart';
part 'package:genetically_evolving_neural_network/models/genn_entity.dart';
part 'package:genetically_evolving_neural_network/models/genn_gene.dart';
part 'package:genetically_evolving_neural_network/models/genn_generation.dart';
part 'package:genetically_evolving_neural_network/models/genn_genetic_evolution_config.dart';
part 'package:genetically_evolving_neural_network/models/genn_neural_network.dart';
part 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
part 'package:genetically_evolving_neural_network/models/genn_perceptron_layer.dart';
part 'package:genetically_evolving_neural_network/models/genn_population.dart';
part 'package:genetically_evolving_neural_network/services/dna_manipulation_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_crossover_service/genn_crossover_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_crossover_service/genn_crossover_service_alignment_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_crossover_service/genn_crossover_service_alignment_perceptron_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_crossover_service/genn_crossover_service_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_dna_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_entity_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_mutation_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_service/genn_gene_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_service/genn_gene_service_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_service/genn_gene_service_mutation_helper.dart';
part 'package:genetically_evolving_neural_network/services/layer_perceptron_alignment_helper.dart';
part 'package:genetically_evolving_neural_network/services/perceptron_layer_mutation_service.dart';
part 'package:genetically_evolving_neural_network/utilities/number_generator.dart';

/// Represents a Genetically Evolving Neural Network.
class GENN extends GeneticEvolution<GENNPerceptron> {
  /// This constructor is visibleForTesting because the [GENNDNAService] and
  /// [GENNGeneMutationService] are not intended to be exposed unless absolutely
  /// necessary.
  @visibleForTesting
  GENN({
    required super.fitnessService,
    required super.geneticEvolutionConfig,
    required super.geneService,
    super.entityService,
    super.populationService,
  });

  /// Creates a [GENN] object.
  ///
  /// This is the recommended constructor when using the [GENN] class.
  factory GENN.create({
    required GENNGeneticEvolutionConfig config,
    required GENNFitnessService fitnessService,
    GENNGeneService? geneService,
    // TODO: Reconsider these for visibleForTesting. Maybe they should be open? Unsure.
    @visibleForTesting GENNEntityService? entityService,
    @visibleForTesting PopulationService<GENNPerceptron>? populationService,
  }) {
    // Use the geneService passed in if any customizations are necessary.
    final gennGeneService = geneService ??
        // Otherwise, generate one internally.
        GENNGeneService(
          numInitialInputs: config.numInitialInputs,
          random: config.random,
        );

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

    final dnaManipulationService = DNAManipulationService(
      gennGeneServiceHelper: gennGeneService.gennGeneServiceHelper,
      fitnessService: fitnessService,
    );

    final layerPerceptronAlignmentHelper = LayerPerceptronAlignmentHelper(
      fitnessService: fitnessService,
      dnaManipulationService: dnaManipulationService,
    );

    final perceptronLayerMutationService = PerceptronLayerMutationService(
      fitnessService: fitnessService,
      gennGeneServiceHelper: gennGeneService.gennGeneServiceHelper,
      random: config.random,
      dnaManipulationService: dnaManipulationService,
      layerPerceptronAlignmentHelper: layerPerceptronAlignmentHelper,
      numOutputs: config.numGenes,
    );

    final crossoverService = GENNCrossoverService(
      perceptronLayerMutationService: perceptronLayerMutationService,
      geneMutationService: geneMutationService,
      numOutputs: config.numGenes,
      layerPerceptronAlignmentHelper: layerPerceptronAlignmentHelper,
    );

    // Use the gennEntityService passed in if any customizations are necessary.
    final gennEntityService = entityService ??
        // Otherwise, generate one internally.
        GENNEntityService(
          dnaService: dnaService,
          fitnessService: fitnessService,
          geneMutationService: geneMutationService,
          trackParents: config.trackParents,
          layerMutationRate: config.layerMutationRate,
          perceptronMutationRate: config.perceptronMutationRate,
          crossoverService: crossoverService,
          generationsToTrack: config.generationsToTrack,
          perceptronLayerMutationService: perceptronLayerMutationService,
        );

    return GENN(
      fitnessService: fitnessService,
      geneticEvolutionConfig: config,
      geneService: gennGeneService,
      entityService: gennEntityService,
      populationService: populationService,
    );
  }

  @override
  Future<GENNGeneration> nextGeneration() async {
    return GENNGeneration.fromGeneration(
      generation: await super.nextGeneration(),
    );
  }
}
