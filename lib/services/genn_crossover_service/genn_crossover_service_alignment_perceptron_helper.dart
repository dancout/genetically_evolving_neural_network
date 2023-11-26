part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNCrossoverServiceAlignmentPerceptronHelper {
  GENNCrossoverServiceAlignmentPerceptronHelper({
    required this.perceptronLayerMutationService,
    // TODO: This should probably not be required
    required this.gennCrossoverServiceHelper,
  });

  final PerceptronLayerMutationService perceptronLayerMutationService;

  final GENNCrossoverServiceHelper gennCrossoverServiceHelper;

  Future<GENNEntity> alignPerceptronLayersWithinEntity({
    required GENNEntity gennEntity,
    required int targetNumLayers,
  }) async {
    var updatedEntity = gennEntity;

    if (updatedEntity.maxLayerNum < targetNumLayers) {
      // We need to add layers to the entity

      final diff = targetNumLayers - updatedEntity.maxLayerNum;

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
    } else if (updatedEntity.maxLayerNum > targetNumLayers) {
      // We need to remove layers from the entity
      final diff = updatedEntity.maxLayerNum - targetNumLayers;

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

  Future<GENNEntity> alignGenesWithinLayer({
    required GENNEntity entity,
    required int targetLayer,
    required int targetGeneNum,
  }) async {
    var updatedEntity = entity;

    // Get how many current genes there are within the target layer.
    final genesWithinTargetLayer = updatedEntity.gennDna.gennGenes
        .where((gennGene) => gennGene.value.layer == targetLayer)
        .length;

    // Check if the genesWithinTargetLayer does not equal the targetGeneNum
    if (genesWithinTargetLayer > targetGeneNum) {
      final diff = genesWithinTargetLayer - targetGeneNum;

      // Remove as many genes as necessary to match the targetGeneNum
      for (int i = 0; i < diff; i++) {
        // Remove perceptron from the entity
        updatedEntity =
            await perceptronLayerMutationService.removePerceptronFromLayer(
          entity: updatedEntity,
          targetLayer: targetLayer,
        );
      }
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
