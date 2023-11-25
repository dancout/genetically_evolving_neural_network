part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNCrossoverServiceAlignmentHelper {
  GENNCrossoverServiceAlignmentHelper({
    required this.numOutputs,
    required this.perceptronLayerMutationService,
    GENNCrossoverServiceHelper? gennCrossoverServiceHelper,
    NumberGenerator? numberGenerator,
  }) : gennCrossoverServiceHelper = gennCrossoverServiceHelper ??
            GENNCrossoverServiceHelper(
              numberGenerator: numberGenerator,
            );

  final GENNCrossoverServiceHelper gennCrossoverServiceHelper;

  /// The number of expected outputs for this NeuralNetwork
  final int numOutputs;

  /// Used to mutate the [GENNPerceptronLayer]s.
  final PerceptronLayerMutationService perceptronLayerMutationService;

  Future<List<GENNEntity>> alignNumLayersForParents({
    required List<GENNEntity> parents,
  }) async {
    final copiedParents = List<GENNEntity>.from(parents);

    int maxLayerNum = gennCrossoverServiceHelper.maxLayerNum(
      parents: copiedParents,
    );

    int minLayerNum = gennCrossoverServiceHelper.minLayerNum(
      maxLayerNum: maxLayerNum,
      parents: copiedParents,
    );

    // Make the maxLayerNum and minLayerNum match
    final targetNumLayers = gennCrossoverServiceHelper.alignMinAndMaxValues(
      maxValue: maxLayerNum,
      minValue: minLayerNum,
    );

    // Cycle through copiedParents
    for (int i = 0; i < copiedParents.length; i++) {
      // If the numbers of layers does not match, then make them match.
      if (copiedParents[i].maxLayerNum != targetNumLayers) {
        copiedParents[i] = await alignPerceptronLayersWithinEntity(
          gennEntity: copiedParents[i],
          targetNumLayers: targetNumLayers,
        );
      }
    }

    return copiedParents;
  }

  Future<List<GENNEntity>> alignGenesWithinLayersForParents({
    required List<GENNEntity> parents,
  }) async {
    final copiedParents = List<GENNEntity>.from(parents);

    // Declare the number of layers expected in each copied parent. Note that we
    // are adding one because the maxLayerNum is 0 indexed.
    final numLayers = copiedParents.first.maxLayerNum + 1;

    for (var copiedParent in copiedParents) {
      assert(
        copiedParent.maxLayerNum == numLayers - 1,
        'All parents must have the same number of layers to align their Genes.',
      );
    }

    // Cycle through each PerceptronLayer
    for (int currLayer = 0; currLayer < numLayers; currLayer++) {
      final perceptronLayersForCurrLayer = <GENNPerceptronLayer>[];

      for (var copiedParent in copiedParents) {
        final perceptronLayerWithinParent = GENNPerceptronLayer(
          gennPerceptrons: copiedParent.gennDna.gennGenes
              .where((gennGene) => gennGene.value.layer == currLayer)
              .map((gene) => gene.value)
              .toList(),
        );

        perceptronLayersForCurrLayer.add(perceptronLayerWithinParent);
      }

      // Check if we are looking at the final layer in the NeuralNetwork.
      final isLastLayer = currLayer == numLayers - 1;

      // Get the target number of perceptrons for this current layer
      final targetNumPerceptrons = isLastLayer
          // If we are on the last layer, then we should use the constant number
          // of expected output values for this Neural Network.
          ? numOutputs
          // Otherwise, choose the number of outputs for this layer.
          : alignNumPerceptronsWithinLayer(
              perceptronLayers: perceptronLayersForCurrLayer,
            );

      // Cycle through each Copied Parent
      for (int x = 0; x < copiedParents.length; x++) {
        // Make the number of Genes within the current layer match the
        // targetNumPerceptrons.
        copiedParents[x] = await alignGenesWithinLayer(
          entity: copiedParents[x],
          targetLayer: currLayer,
          targetGeneNum: targetNumPerceptrons,
        );
      }
    }

    return copiedParents;
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
}
