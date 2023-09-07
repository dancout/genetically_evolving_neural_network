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
      final weights = List<double>.generate(perceptrons.length, (index) => 0.0);

      // Set this perceptron's adjacent, previous weight to 1.0. This will
      // effectively pass through the previous perceptron's value forward.
      // weights[i] = perceptrons[i].weights[i];
      weights[i] = 1.0;

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
    final gennGenes = entity.gennDna.gennGenes;

    final numWeightsOfTargetLayer = entity.gennDna.gennGenes
        .firstWhere((gennGene) => gennGene.value.layer == targetLayer)
        .value
        .weights
        .length;

    // Remove all genes from targetLayer
    gennGenes.removeWhere((gene) => gene.value.layer == targetLayer);

    // Decrement all layers after targetLayer
    final genesAfterRemoval = gennGenes.map(
      (gennGene) {
        if (gennGene.value.layer > targetLayer) {
          return gennGene.copyWith(
            value: gennGene.value.copyWith(layer: gennGene.value.layer - 1),
          );
        }
        return gennGene;
      },
    );

    // Update the weights for the genes now currently in the targetLayer
    // position. This is necessary because the number of perceptrons may not
    // have remained consistent from the previous layer to the target layer
    // after the removal.
    final genesWithUpdatedWeights = genesAfterRemoval.map((gene) {
      if (gene.value.layer == targetLayer) {
        final newWeights = List.generate(
          numWeightsOfTargetLayer,
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
    // TODO: Do we need this assert? Or is it overkill and inefficient?
    assert(
      targetLayer < entity.maxLayerNum,
      'Cannot add Perceptrons to the last perceptron layer. '
      'This is the output layer and has a fixed number of perceptrons.',
    );

    final genes = entity.gennDna.gennGenes;

    // Grab the number of weights necessary from another gene from the
    // targetLayer.
    final numWeights = genes
        .firstWhere((gene) => gene.value.layer == targetLayer)
        .value
        .weights
        .length;

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

        final weights = List<double>.from(perceptron.weights);
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
    // TODO: Do we need this assert, or should we remove for efficiency?
    assert(
      entity.gennDna.gennGenes
              .where((gennGene) => gennGene.value.layer == targetLayer)
              .length >
          1,
      'Cannot remove the only Perceptron from a given layer.',
    );

    var genes = entity.gennDna.gennGenes;

    final targetLayerGenes = List.from(
        genes.where((gene) => gene.value.layer == targetLayer).toList());

    final randIndex = random.nextInt(targetLayerGenes.length);

    final targetPerceptron = targetLayerGenes[randIndex];

    genes.remove(targetPerceptron);

    genes = genes.map((gene) {
      if (gene.value.layer == targetLayer + 1) {
        final weights = List<double>.from(gene.value.weights);
        // Remove the weight connected to the removed perceptron
        weights.removeAt(randIndex);

        return gene.copyWith(
          value: gene.value.copyWith(weights: weights),
        );
      }
      return gene;
    }).toList();

    final dna = GENNDNA(gennGenes: genes);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);

    return entity.copyWith(
      gennDna: dna,
      fitnessScore: fitnessScore,
    );
  }
}
