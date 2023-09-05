import 'dart:math';

import 'package:genetically_evolving_neural_network/models/genn_dna.dart';
import 'package:genetically_evolving_neural_network/models/genn_entity.dart';
import 'package:genetically_evolving_neural_network/models/genn_gene.dart';
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
    final duplicatedPerceptrons = <GENNPerceptron>[];

    final perceptrons = gennPerceptronLayer.gennPerceptrons;
    for (int i = 0; i < perceptrons.length; i++) {
      // Set all weights to 0 so they ignore input
      final weights =
          List<double>.generate(perceptrons[i].weights.length, (index) => 0.0);

      // Set this perceptron's adjacent, previous weight to its existing value.
      // This will effectively pass through the previous perceptron's value
      // forward.
      weights[i] = perceptrons[i].weights[i];

      duplicatedPerceptrons.add(
        GENNPerceptron(
          bias: perceptrons[i].bias,
          threshold: perceptrons[i].threshold,
          weights: weights,
          layer: perceptrons[i].layer + 1,
        ),
      );
    }

    return GENNPerceptronLayer(gennPerceptrons: duplicatedPerceptrons);
  }

  GENNEntity addPerceptronLayer({
    required GENNEntity entity,
    required GENNPerceptronLayer perceptronLayer,
  }) {
    final duplicationLayer = perceptronLayer.gennPerceptrons.first.layer - 1;

    // Increment all layers after duplicationLayer
    final genes = entity.gennDna.gennGenes.map((gene) {
      if (gene.value.layer > duplicationLayer) {
        return gene.copyWith(
          value: gene.value.copyWith(layer: gene.value.layer + 1),
        );
      }
      return gene;
    }).toList();

    // Add duplicated layer to genes
    genes.addAll(
      perceptronLayer.gennPerceptrons.map(
        (perceptron) => GENNGene(
          value: perceptron,
        ),
      ),
    );

    return entity.copyWith(
      gennDna: GENNDNA(gennGenes: genes),
    );
  }

  Future<GENNEntity> removePerceptronLayerFromEntity({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    // Grab the genes from the given Entity
    final genes = entity.gennDna.gennGenes;

    // Remove all genes from targetLayer
    genes.removeWhere((gene) => gene.value.layer == targetLayer);

    // Decrement all layers after targetLayer
    final genesAfterRemoval = genes.map((gene) {
      if (gene.value.layer > targetLayer) {
        return gene.copyWith(
          value: gene.value.copyWith(layer: gene.value.layer - 1),
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
        return gene.copyWith(
          value: gene.value.copyWith(weights: newWeights),
        );
      }
      // Return the unchanged Gene
      return gene;
    }).toList();

    final dna = GENNDNA(gennGenes: genesWithUpdatedWeights);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);

    return entity.copyWith(
      gennDna: dna,
      fitnessScore: fitnessScore,
    );
  }

  Future<GENNEntity> addPerceptronToLayer({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    assert(
        targetLayer > 0, 'Cannot add Perceptrons to the initial input layer');
    // TODO: Does this need to be List.from so we're not editing the *actual*
    /// list in place? OR, would that be a better idea for efficiency?
    final genes = entity.gennDna.gennGenes;

    final numWeights =
        genes.where((gene) => gene.value.layer == targetLayer - 1).length;

    genes.add(
      GENNGene(
        value: geneService.randomPerceptron(
          numWeights: numWeights,
          layer: targetLayer,
        ),
      ),
    );

    for (int i = 0; i < genes.length; i++) {
      if (genes[i].value.layer == targetLayer + 1) {
        final gene = genes[i];
        final perceptron = gene.value;

        final weights = perceptron.weights;
        weights.add(geneService.randomNegOneToPosOne);

        genes[i] = gene.copyWith(
          value: perceptron.copyWith(weights: weights),
        );
      }
    }

    final dna = GENNDNA(gennGenes: genes);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);
    return entity.copyWith(
      gennDna: dna,
      fitnessScore: fitnessScore,
    );
  }

  Future<GENNEntity> removePerceptronFromLayer({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    final genes = List<GENNGene>.from(entity.gennDna.gennGenes);

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

        return gene.copyWith(
          value: gene.value.copyWith(weights: weights),
        );
      }
      return gene;
    }).toList();

    final dna = GENNDNA(gennGenes: updatedGenes);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);

    return entity.copyWith(
      gennDna: dna,
      fitnessScore: fitnessScore,
    );
  }
}
