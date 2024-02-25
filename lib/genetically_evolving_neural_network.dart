library genetically_evolving_neural_network;

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

part 'genetically_evolving_neural_network.g.dart';
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
part 'package:genetically_evolving_neural_network/services/entity_manipulation_service.dart';
part 'package:genetically_evolving_neural_network/services/entity_manipulation_service_addition_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_crossover_service/genn_crossover_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_crossover_service/genn_crossover_service_alignment_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_crossover_service/genn_crossover_service_alignment_perceptron_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_crossover_service/genn_crossover_service_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_dna_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_entity_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_entity_service_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_mutation_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_service/genn_gene_service.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_service/genn_gene_service_helper.dart';
part 'package:genetically_evolving_neural_network/services/genn_gene_service/genn_gene_service_mutation_helper.dart';
part 'package:genetically_evolving_neural_network/services/perceptron_layer_alignment_helper.dart';
part 'package:genetically_evolving_neural_network/utilities/gene_json_converter.dart';
part 'package:genetically_evolving_neural_network/utilities/generation_json_converter.dart';
part 'package:genetically_evolving_neural_network/utilities/genn_file_parser.dart';
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
    super.geneJsonConverter,
    required super.fileParser,
  });

  /// Creates a [GENN] object.
  ///
  /// This is the recommended constructor when using the [GENN] class.
  factory GENN.create({
    required GENNGeneticEvolutionConfig config,
    required GENNFitnessService fitnessService,
    GENNGeneService? geneService,
    GENNEntityService? entityService,
    PopulationService<GENNPerceptron>? populationService,
    JsonConverter? geneJsonConverter,
  }) {
    // Use the geneService passed in if any customizations are necessary.
    final gennGeneService = geneService ??
        // Otherwise, generate one internally.
        GENNGeneService(
          numInitialInputs: config.numInitialInputs,
          random: config.random,
        );

    final numberGenerator = NumberGenerator(
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
    );

    final perceptronLayerAlignmentHelper = PerceptronLayerAlignmentHelper(
      fitnessService: fitnessService,
      dnaManipulationService: dnaManipulationService,
    );

    final entityManipulationServiceHelper =
        EntityManipulationServiceAdditionHelper(
      fitnessService: fitnessService,
    );
    final entityManipulationService = EntityManipulationService(
      entitymanipulationServiceAdditionHelper: entityManipulationServiceHelper,
      fitnessService: fitnessService,
      random: config.random,
      dnaManipulationService: dnaManipulationService,
      perceptronLayerAlignmentHelper: perceptronLayerAlignmentHelper,
      numOutputs: config.numGenes,
    );

    final gennCrossoverServiceHelper = GENNCrossoverServiceHelper(
      numberGenerator: numberGenerator,
    );
    final gennCrossoverServiceAlignmentPerceptronHelper =
        GENNCrossoverServiceAlignmentPerceptronHelper(
      entityManipulationService: entityManipulationService,
      gennCrossoverServiceHelper: gennCrossoverServiceHelper,
    );
    final crossoverService = GENNCrossoverService(
      gennCrossoverServiceAlignmentHelper: GENNCrossoverServiceAlignmentHelper(
        gennCrossoverServiceAlignmentPerceptronHelper:
            gennCrossoverServiceAlignmentPerceptronHelper,
        numOutputs: config.numGenes,
        perceptronLayerAlignmentHelper: perceptronLayerAlignmentHelper,
      ),
      geneMutationService: geneMutationService,
    );

    final entityParentManinpulator = EntityParentManinpulator<GENNPerceptron>(
      trackParents: config.trackParents,
      generationsToTrack: config.generationsToTrack,
    );

    // Use the gennEntityService passed in if any customizations are necessary.
    final gennEntityService = entityService ??
        // Otherwise, generate one internally.
        GENNEntityService(
          dnaService: dnaService,
          fitnessService: fitnessService,
          geneMutationService: geneMutationService,
          crossoverService: crossoverService,
          entityParentManinpulator: entityParentManinpulator,
          gennEntityServiceHelper: GENNEntityServiceHelper(
            entityManipulationService: entityManipulationService,
            numberGenerator: numberGenerator,
            layerMutationRate: config.layerMutationRate,
            perceptronMutationRate: config.perceptronMutationRate,
          ),
        );

    // Used to convert GENNGenerations to be written onto and read from files.
    GENNFileParser gennFileParser = GENNFileParser(
      geneJsonConverter: GeneJsonConverter(),
      generationJsonConverter: GenerationJsonConverter(),
    );

    return GENN(
      fitnessService: fitnessService,
      geneticEvolutionConfig: config,
      geneService: gennGeneService,
      entityService: gennEntityService,
      populationService: populationService,
      geneJsonConverter: geneJsonConverter ?? GeneJsonConverter(),
      fileParser: gennFileParser,
    );
  }

  @override
  Future<GENNGeneration> nextGeneration() async {
    return GENNGeneration.fromGeneration(
      generation: await super.nextGeneration(),
    );
  }
}
