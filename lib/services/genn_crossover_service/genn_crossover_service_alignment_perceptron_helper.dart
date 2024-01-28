part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Used to update the number of [Gene] objects within a [PerceptronLayer],
/// and the number of [PerceptronLayer] objects within a [GENNEntity].
class GENNCrossoverServiceAlignmentPerceptronHelper {
  /// Used to update the number of [Gene] objects within a [PerceptronLayer],
  /// and the number of [PerceptronLayer] objects within a [GENNEntity].
  GENNCrossoverServiceAlignmentPerceptronHelper({
    required this.perceptronLayerMutationService,
    required this.gennCrossoverServiceHelper,
  });

  /// Used for mutating Perceptron Layers on the Entities.
  final PerceptronLayerMutationService perceptronLayerMutationService;

  /// Used to assist with cross-breeding Entities.
  final GENNCrossoverServiceHelper gennCrossoverServiceHelper;

  /// Returns an updated [gennEntity] that now has [targetNumLayers] number of
  /// Perceptron Layers.
  Future<GENNEntity> alignPerceptronLayersWithinEntity({
    required GENNEntity gennEntity,
    required int targetNumLayers,
    // TODO: Should this be what we pass in? Also should be on class object.
    required GENNCrossoverServiceAlignmentHelper
        gENNCrossoverServiceAlignmentHelper,
  }) async {
    // TODO: Is this copywith necessary?
    var updatedEntity = gennEntity.copyWith();

    if (updatedEntity.maxLayerNum < targetNumLayers) {
      // We need to add layers to the entity

      final diff = targetNumLayers - updatedEntity.maxLayerNum;

      for (int i = 0; i < diff; i++) {
        final lastLayerNum = updatedEntity.maxLayerNum;

        // Extract the last PeceptronLayer on the entity
        final lastPerceptronLayer = GENNPerceptronLayer(
          perceptrons: updatedEntity.dna.genes
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
    } else if (updatedEntity.maxLayerNum > targetNumLayers) {
      // We need to remove layers from the entity
      final diff = updatedEntity.maxLayerNum - targetNumLayers;

      for (int i = 0; i < diff; i++) {
        // Remove the last PerceptronLayer from Entity
        updatedEntity = await perceptronLayerMutationService
            .removePerceptronLayerFromEntity(
          entity: updatedEntity,
          targetLayer: updatedEntity.maxLayerNum,
          gENNCrossoverServiceAlignmentHelper:
              gENNCrossoverServiceAlignmentHelper,
        );
      }
    }

    return updatedEntity;
  }

  /// Returns an updated [entity] that now has [targetGeneNum] genes within the
  /// PerceptronLayer matching [targetLayer].
  Future<GENNEntity> alignGenesWithinLayer({
    required GENNEntity entity,
    required int targetLayer,
    required int targetGeneNum,
  }) async {
    // TODO: Is this copywith necessary?
    var updatedEntity = entity.copyWith();

    // Get how many current genes there are within the target layer.
    final genesWithinTargetLayer = updatedEntity.dna.genes
        .where((gennGene) => gennGene.value.layer == targetLayer)
        .length;

    // Check if the genesWithinTargetLayer does not equal the targetGeneNum
    if (genesWithinTargetLayer > targetGeneNum) {
      // Calculate the difference between the target and actual number of genes
      // within this layer.
      final diff = genesWithinTargetLayer - targetGeneNum;

      // Declare a copy of the updated Entity's DNA.
      var updatedDNA = updatedEntity.dna;

      // Remove as many genes as necessary to match the targetGeneNum
      for (int i = 0; i < diff; i++) {
        // Store the updated GENNDNA after removing a perceptron
        updatedDNA = perceptronLayerMutationService.removePerceptronFromDNA(
          dna: updatedDNA,
          targetLayer: targetLayer,
        );
      }

      // Declare the updated FitnessScore from your updated DNA
      final updatedFitnessScore = await perceptronLayerMutationService
          .fitnessService
          .calculateScore(dna: updatedDNA);

      // Update the entity with its updated DNA and updated Fitness Score.
      updatedEntity = updatedEntity.copyWith(
        dna: updatedDNA,
        fitnessScore: updatedFitnessScore,
      );
    } else if (genesWithinTargetLayer < targetGeneNum) {
      final diff = targetGeneNum - genesWithinTargetLayer;

      // Add as many genes as necessary to match the targetGeneNum
      for (int i = 0; i < diff; i++) {
        // Add perceptron to the entity
        updatedEntity =
            await perceptronLayerMutationService.addPerceptronToLayer(
          entity: updatedEntity,
          targetLayer: targetLayer,
        );
      }
    }

    // Return the potentially updated entity
    return updatedEntity;
  }

  /// Returns an [int] between the max and min number of perceptrons within the
  /// incoming [perceptronLayers].
  int alignNumPerceptronsWithinLayer({
    required List<GENNPerceptronLayer> perceptronLayers,
  }) {
    int maxNumPerceptrons = perceptronLayers.fold(
      0,
      (previousValue, gennPerceptronLayer) =>
          (previousValue > gennPerceptronLayer.numPerceptrons)
              ? previousValue
              : gennPerceptronLayer.numPerceptrons,
    );

    int minNumPerceptrons = perceptronLayers.fold(
      maxNumPerceptrons,
      (previousValue, gennPerceptronLayer) =>
          (previousValue < gennPerceptronLayer.numPerceptrons)
              ? previousValue
              : gennPerceptronLayer.numPerceptrons,
    );

    return gennCrossoverServiceHelper.alignMinAndMaxValues(
      maxValue: maxNumPerceptrons,
      minValue: minNumPerceptrons,
    );
  }
}
