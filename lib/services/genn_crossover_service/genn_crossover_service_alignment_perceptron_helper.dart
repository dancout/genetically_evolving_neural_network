part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Used to update the number of [Gene] objects within a [PerceptronLayer],
/// and the number of [PerceptronLayer] objects within a [GENNEntity].
class GENNCrossoverServiceAlignmentPerceptronHelper {
  /// Used to update the number of [Gene] objects within a [PerceptronLayer],
  /// and the number of [PerceptronLayer] objects within a [GENNEntity].
  GENNCrossoverServiceAlignmentPerceptronHelper({
    required this.gennCrossoverServiceHelper,
    required this.entityManipulationService,
  });

  /// Used for mutating [GENNEntity] objects;
  final EntityManipulationService entityManipulationService;

  /// Used to assist with cross-breeding Entities.
  final GENNCrossoverServiceHelper gennCrossoverServiceHelper;

  /// Returns an updated [gennEntity] that now has [targetNumLayers] number of
  /// Perceptron Layers.
  Future<GENNEntity> alignPerceptronLayersWithinEntity({
    required GENNEntity gennEntity,
    required int targetNumLayers,
  }) async {
    if (gennEntity.maxLayerNum < targetNumLayers) {
      // We need to add layers to the entity

      final diff = targetNumLayers - gennEntity.maxLayerNum;

      for (int i = 0; i < diff; i++) {
        // Add PerceptronLayer into Entity
        gennEntity = await entityManipulationService
            .duplicatePerceptronLayerWithinEntity(
          entity: gennEntity,
          targetLayer: gennEntity.maxLayerNum,
        );
      }
    } else if (gennEntity.maxLayerNum > targetNumLayers) {
      // We need to remove layers from the entity
      final diff = gennEntity.maxLayerNum - targetNumLayers;

      for (int i = 0; i < diff; i++) {
        // Remove the last PerceptronLayer from Entity
        gennEntity =
            await entityManipulationService.removePerceptronLayerFromEntity(
          entity: gennEntity,
          targetLayer: gennEntity.maxLayerNum,
        );
      }
    }

    return gennEntity;
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
