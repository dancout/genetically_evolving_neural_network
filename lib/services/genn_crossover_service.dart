import 'dart:math';

import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_entity.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron_layer.dart';
import 'package:genetically_evolving_neural_network/services/perceptron_layer_mutation_service.dart';

class GENNCrossoverService extends CrossoverService<GENNPerceptron> {
  GENNCrossoverService({
    required super.dnaService,
    required super.geneMutationService,
    required this.perceptronLayerMutationService,
    Random? random,
  }) : random = random ?? Random();

  final PerceptronLayerMutationService perceptronLayerMutationService;
  final Random random;

  @override
  Future<List<Gene<GENNPerceptron>>> crossover({
    required List<Entity<GENNPerceptron>> parents,
    required List<int> randIndices,
    required int wave,
  }) async {
    // Make the parents match up in structure (both num layers and num
    // perceptrons in each layer).
    final copiedParents = List<GENNEntity>.generate(
        parents.length, (index) => parents[index] as GENNEntity);

    int maxLayerNum = copiedParents.fold(
        0,
        (previousValue, gennEntity) => (previousValue > gennEntity.maxLayerNum)
            ? previousValue
            : gennEntity.maxLayerNum);

    int minLayerNum = copiedParents.fold(
        maxLayerNum,
        (previousValue, gennEntity) => (previousValue < gennEntity.maxLayerNum)
            ? previousValue
            : gennEntity.maxLayerNum);

    // Make the maxLayerNum and minLayerNum match
    final targetLayerNum = alignMinAndMaxValues(
      maxLayerNum: maxLayerNum,
      minLayerNum: minLayerNum,
    );

    // Cycle through copiedParents
    for (int i = 0; i < copiedParents.length; i++) {
      // If the numbers of layers does not match, then make them match.
      if (copiedParents[i].maxLayerNum != targetLayerNum) {
        copiedParents[i] = await alignPerceptronLayerNum(
          gennEntity: copiedParents[i],
          targetLayerNum: targetLayerNum,
        );
      }
    }

    // TODO: Implement making the number of perceptrons in each layer match
    // Cycle through copiedParents
    for (int i = 0; i < copiedParents.length; i++) {
      // If the numbers of perceptrons within each layer does not match, then
      // make them match.
    }

    // then return the super.crossover with the updated parents.

    return super.crossover(
      parents: parents,
      randIndices: randIndices,
      wave: wave,
    );
  }

  Future<GENNEntity> alignPerceptronLayerNum({
    required GENNEntity gennEntity,
    required int targetLayerNum,
  }) async {
    var updatedEntity = gennEntity;

    if (updatedEntity.maxLayerNum < targetLayerNum) {
      // We need to add layers to the entity

      final diff = targetLayerNum - updatedEntity.maxLayerNum;

      for (int i = 0; i < diff; i++) {
        final lastLayerNum = updatedEntity.maxLayerNum;

        // Extract the last PeceptronLayer on the entity
        final lastPerceptronLayer = GENNPerceptronLayer(
          gennPerceptrons: updatedEntity.gennDna.gennGenes
              .where((gennGene) => gennGene.value.layer == lastLayerNum)
              .map((gennGene) => gennGene.value)
              .toList(),
        );

        // Duplicate the last PerceptronLayer
        final duplicatedPerceptronLayer =
            perceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: lastPerceptronLayer,
        );

        // Add PerceptronLayer into Entity
        updatedEntity = perceptronLayerMutationService.addPerceptronLayer(
          entity: updatedEntity,
          perceptronLayer: duplicatedPerceptronLayer,
        );
      }
    } else if (updatedEntity.maxLayerNum > targetLayerNum) {
      // We need to remove layers from the entity
      final diff = updatedEntity.maxLayerNum - targetLayerNum;

      for (int i = 0; i < diff; i++) {
        // Remove the last PerceptronLayer from Entity
        updatedEntity = await perceptronLayerMutationService
            .removePerceptronLayerFromEntity(
          entity: updatedEntity,
          targetLayer: updatedEntity.maxLayerNum,
        );
      }
    }

    return updatedEntity;
  }

  int alignMinAndMaxValues({
    required int maxLayerNum,
    required int minLayerNum,
  }) {
    assert(
      maxLayerNum >= minLayerNum,
      'maxLayerNum must be greater than or equal to minLayerNum',
    );

    while (maxLayerNum != minLayerNum) {
      if (random.nextBool()) {
        // Increment the min value towards the max value
        minLayerNum++;
      } else {
        // Decrement the max value towards the min value
        maxLayerNum--;
      }
    }
    return maxLayerNum;
  }
}
