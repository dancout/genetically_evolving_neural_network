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
        updatedEntity =
            perceptronLayerMutationService.addPerceptronLayerToEntity(
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
