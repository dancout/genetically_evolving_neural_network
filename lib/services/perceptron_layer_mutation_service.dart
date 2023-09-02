import 'dart:math';

import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron_layer.dart';
import 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_service.dart';

class PerceptronLayerMutationService {
  PerceptronLayerMutationService({
    required this.geneService,
    required this.fitnessService,
    Random? random,
  }) : random = random ?? Random();
  final GENNFitnessService fitnessService;
  final GENNGeneService geneService;
  final Random random;

  /// Returns a [GENNPerceptronLayer] that is duplicated from the input
  /// [gennPerceptronLayer] with the weights adjusted so the [GENNPerceptron]
  /// objects will only receive input from their adjacent, previous neighbor.
  /// TODO: Include example in this doc.
  GENNPerceptronLayer duplicatePerceptronLayer({
    required GENNPerceptronLayer gennPerceptronLayer,
  }) {
    final perceptrons = <GENNPerceptron>[];

    for (int i = 0; i < perceptrons.length; i++) {
      // Set all weights to 0 so they ignore input
      final weights =
          List<double>.generate(perceptrons[i].weights.length, (index) => 0.0);

      // Set this perceptron's adjacent, previous weight to its existing value.
      // This will effectively pass through the previous perceptron's value
      // forward.
      weights[i] = perceptrons[i].weights[i];

      perceptrons.add(
        GENNPerceptron(
          bias: perceptrons[i].bias,
          threshold: perceptrons[i].threshold,
          weights: weights,
          layer: perceptrons[i].layer + 1,
        ),
      );
    }

    return GENNPerceptronLayer(gennPerceptrons: perceptrons);
  }

  Entity<GENNPerceptron> addPerceptronLayer({
    required Entity<GENNPerceptron> entity,
    required GENNPerceptronLayer perceptronLayer,
  }) {
    final duplicationLayer = perceptronLayer.gennPerceptrons.first.layer - 1;

    // Increment all layers after duplicationLayer
    final genes = entity.dna.genes.map((gene) {
      if (gene.value.layer > duplicationLayer) {
        return Gene(
          value: gene.value.copyWith(layer: gene.value.layer + 1),
          mutatedWaves: gene.mutatedWaves,
        );
      }
      return gene;
    }).toList();

    // Add duplicated layer to genes
    genes.addAll(
      perceptronLayer.gennPerceptrons
          .map((perceptron) => Gene(value: perceptron)),
    );

    return Entity(
      dna: DNA(genes: genes),
      fitnessScore: entity.fitnessScore,
      parents: entity.parents,
    );
  }

  Future<Entity<GENNPerceptron>> removePerceptronLayerFromEntity({
    required Entity<GENNPerceptron> entity,
    required int targetLayer,
  }) async {
    // Grab the genes from the given Entity
    final genes = entity.dna.genes;

    // Remove all genes from targetLayer
    genes.removeWhere((gene) => gene.value.layer == targetLayer);

    // Decrement all layers after targetLayer
    final genesAfterRemoval = genes.map((gene) {
      if (gene.value.layer > targetLayer) {
        return Gene(
          value: gene.value.copyWith(layer: gene.value.layer - 1),
          mutatedWaves: gene.mutatedWaves,
        );
      }
      return gene;
    }).toList();

    final numWeightsUpdatedTargetLayer = genesAfterRemoval
        .where((gene) => gene.value.layer == targetLayer - 1)
        .toList()
        .length;

    // Update the weights for the genes now currently in the targetLayer
    // position. This is necessary because the number of perceptrons may not
    // have remained consistent from the previous layer to the target layer
    // after the removal.
    final genesWithUpdatedWeights = genesAfterRemoval.map((gene) {
      if (gene.value.layer == targetLayer) {
        final newWeights = List.generate(
          numWeightsUpdatedTargetLayer,
          (_) => geneService.randomNegOneToPosOne,
        );

        // Return the updated Gene within the targetLayer
        return Gene(
          value: gene.value.copyWith(weights: newWeights),
          mutatedWaves: gene.mutatedWaves,
        );
      }
      // Return the unchanged Gene
      return gene;
    }).toList();

    final dna = DNA(genes: genesWithUpdatedWeights);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);

    return Entity(
      dna: dna,
      fitnessScore: fitnessScore,
      // TODO: Create a copyWith for Entity so we don't forget fields like parents
      parents: entity.parents,
    );
  }

  Future<Entity<GENNPerceptron>> addPerceptronToLayer({
    required Entity<GENNPerceptron> entity,
    required int targetLayer,
  }) async {
    assert(
        targetLayer > 0, 'Cannot add Perceptrons to the initial input layer');
    // TODO: Does this need to be List.from so we're not editing the *actual*
    /// list in place? OR, would that be a better idea for efficiency?
    final genes = entity.dna.genes;

    final numWeights =
        genes.where((gene) => gene.value.layer == targetLayer - 1).length;

    genes.add(
      Gene(
        value: geneService.randomPerceptron(
          numWeights: numWeights,
          layer: targetLayer,
        ),
      ),
    );

    for (int i = 0; i < genes.length; i++) {
      if (genes[i].value.layer == targetLayer + 1) {
        final perceptron = genes[i].value;

        final weights = perceptron.weights;
        weights.add(geneService.randomNegOneToPosOne);

        genes[i] = Gene(
          value: perceptron.copyWith(weights: weights),
          mutatedWaves: genes[i].mutatedWaves,
        );
      }
    }

    final dna = DNA(genes: genes);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);
    return Entity(
      dna: dna,
      fitnessScore: fitnessScore,
      parents: entity.parents,
    );
  }

  Future<Entity<GENNPerceptron>> removePerceptronFromLayer({
    required Entity<GENNPerceptron> entity,
    required int targetLayer,
  }) async {
    final genes = List<Gene<GENNPerceptron>>.from(entity.dna.genes);

    final targetLayerGenes = List.from(
        genes.where((gene) => gene.value.layer == targetLayer).toList());

    final randIndex = random.nextInt(targetLayerGenes.length);

    final targetPerceptron = targetLayerGenes[randIndex];

    genes.remove(targetPerceptron);

    final updatedGenes = genes.map((gene) {
      if (gene.value.layer > targetLayer) {
        final weights = List<double>.from(gene.value.weights);
        // Remove the weight connected to the removed perceptron
        weights.removeAt(randIndex);

        // TODO: A Gene.copyWith would be safer than passing mutatedWaves in every time.
        return Gene(
          value: gene.value.copyWith(weights: weights),
          mutatedWaves: gene.mutatedWaves,
        );
      }
      return gene;
    }).toList();

    final dna = DNA(genes: updatedGenes);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);

    return Entity(
      dna: dna,
      fitnessScore: fitnessScore,
      parents: entity.parents,
    );
  }
}
