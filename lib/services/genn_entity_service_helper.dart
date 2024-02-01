part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNEntityServiceHelper {
  GENNEntityServiceHelper(
      // TODO: Double check all the required params here
      {
    required this.numberGenerator,
    required this.layerMutationRate,
    required this.perceptronMutationRate,
    required this.perceptronLayerMutationService,
  });

  /// Used to generate random numbers and bools.
  final NumberGenerator numberGenerator;

  /// The rate at which a PerceptronLayer will be added or removed from an
  /// Entity.
  final double layerMutationRate;

  /// The rate at which a Perceptron will be added or removed from a given
  /// PerceptronLayer.
  final double perceptronMutationRate;

  /// Used for mutating Perceptron Layers on the Entities.
  late final PerceptronLayerMutationService perceptronLayerMutationService;

  Future<GENNEntity> mutatePerceptronLayersWithinEntity({
    required GENNEntity child,
    // required double randNumber,
  }) async {
    // TODO: Is the copywith necessary?
    var updatedChild = child.copyWith();

    final randNumber = numberGenerator.nextDouble;
    final gennNN = GENNNeuralNetwork.fromGenes(
      genes: List<GENNGene>.from(updatedChild.dna.genes),
    );
    var numLayers = gennNN.numLayers;

    // Add or Remove PerceptronLayer from Entity if mutation condition met.
    if (randNumber < layerMutationRate) {
      // NOTE: If there is only a single layer, then we cannot remove it, so we
      // must add to it.
      if (numLayers == 1 || numberGenerator.nextBool) {
        // Randomly pick a layer to duplicate
        final duplicationLayer = numberGenerator.nextInt(numLayers);

        // Duplicate PerceptronLayer
        final duplicatedPerceptronLayer =
            perceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: gennNN.layers[duplicationLayer],
        );

        // Add PerceptronLayer into Entity
        updatedChild =
            await perceptronLayerMutationService.addPerceptronLayerToEntity(
          entity: updatedChild,
          perceptronLayer: duplicatedPerceptronLayer,
        );
        // Increment the number of Perceptron Layers
        numLayers++;
      } else {
        // NOTE:  Cannot remove last layer, hence the -1. This is because the
        //        last layer represents the expected outputs, and that cannot
        //        change.
        final targetLayer = numberGenerator.nextInt(numLayers - 1);

        // Remove PerceptronLayer from Entity
        updatedChild = await perceptronLayerMutationService
            .removePerceptronLayerFromEntity(
          entity: updatedChild,
          targetLayer: targetLayer,
        );
        // Decrement the number of Perceptron Layers
        numLayers--;
      }
    }

    return updatedChild;
  }

  Future<GENNEntity> mutatePerceptronsWithinLayer({
    required GENNEntity child,
    // required double randNumber,
  }) async {
    // TODO: Is the copywith necessary?
    var updatedChild = child.copyWith();

    // TODO: EXTRA DOUBLE CHECK ON THIS! I AM CREATING THIS ON THE FLY INSTEAD
    /// OF USING IT PASSED FORWARD!
    // final numLayers = updatedChild.maxLayerNum + 1;
    final gennNN = GENNNeuralNetwork.fromGenes(genes: updatedChild.dna.genes);
    var numLayers = gennNN.numLayers;

    final randNumber = numberGenerator.nextDouble;

    // Add or Remove a Perceptron from a PerceptronLayer if there is more than
    // one layer.
    if (numLayers > 1 && randNumber < perceptronMutationRate) {
      // NOTE:  Cannot update the last layer, hence the -1. This is because the
      //        last layer represents the expected outputs, and that cannot
      //        change.
      final targetLayer = numberGenerator.nextInt(numLayers - 1);

      // Calculate the number of Genes in the target layer
      final numGenesInTargetLayer = updatedChild.dna.genes
          .where((gene) => gene.value.layer == targetLayer)
          .length;

      // Cannot remove from a layer that only has 1 perceptron
      if ((numGenesInTargetLayer == 1) || numberGenerator.nextBool) {
        updatedChild =
            await perceptronLayerMutationService.addPerceptronToLayer(
          entity: updatedChild,
          targetLayer: targetLayer,
        );
      } else {
        updatedChild =
            await perceptronLayerMutationService.removePerceptronFromLayer(
          entity: updatedChild,
          targetLayer: targetLayer,
        );
      }
    }

    return updatedChild;
  }
}
