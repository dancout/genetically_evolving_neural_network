part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class is responsible for adding or removing [GENNPerceptron] objects
/// within a [GENNPerceptronLayer] and adding or removing [GENNPerceptronLayer]
/// objects from a [GENNEntity].
class GENNEntityServiceHelper {
  /// This class is responsible for adding or removing [GENNPerceptron] objects
  /// within a [GENNPerceptronLayer] and adding or removing
  /// [GENNPerceptronLayer] objects from a [GENNEntity].
  GENNEntityServiceHelper({
    Random? random,
    NumberGenerator? numberGenerator,
    required this.layerMutationRate,
    required this.perceptronMutationRate,
    required this.entityManipulationService,
  }) : numberGenerator = numberGenerator ?? NumberGenerator(random: random);

  /// Used to generate random numbers and bools.
  final NumberGenerator numberGenerator;

  /// The rate at which a PerceptronLayer will be added or removed from an
  /// Entity.
  final double layerMutationRate;

  /// The rate at which a Perceptron will be added or removed from a given
  /// PerceptronLayer.
  final double perceptronMutationRate;

  /// Used for mutating [GENNEntity] objects;
  final EntityManipulationService entityManipulationService;

  /// Adds or removes a [GENNPerceptronLayer] to the input [child].
  Future<GENNEntity> mutatePerceptronLayersWithinEntity({
    required GENNEntity child,
  }) async {
    final randNumber = numberGenerator.nextDouble;
    final numLayers = child.maxLayerNum + 1;

    // Add or Remove PerceptronLayer from Entity if mutation condition met.
    if (randNumber < layerMutationRate) {
      // NOTE: If there is only a single layer, then we cannot remove it, so we
      // must add to it.
      if (numLayers == 1 || numberGenerator.nextBool) {
        // Randomly pick a layer to duplicate
        final targetLayer = numberGenerator.nextInt(numLayers);

        // Duplicate the PerceptronLayer within the entity
        child = await entityManipulationService
            .duplicatePerceptronLayerWithinEntity(
          entity: child,
          targetLayer: targetLayer,
        );
      } else {
        // NOTE:  Cannot remove last layer, hence the -1. This is because the
        //        last layer represents the expected outputs, and that cannot
        //        change.
        final targetLayer = numberGenerator.nextInt(numLayers - 1);

        // Remove PerceptronLayer from Entity
        child = await entityManipulationService.removePerceptronLayerFromEntity(
          entity: child,
          targetLayer: targetLayer,
        );
      }
    }

    return child;
  }

  /// Adds or removes a [GENNPerceptron] to a random [GENNPerceptronLayer]
  /// within the input [child].
  Future<GENNEntity> mutatePerceptronsWithinLayer({
    required GENNEntity child,
  }) async {
    final numLayers = child.maxLayerNum + 1;
    final randNumber = numberGenerator.nextDouble;

    // Add or Remove a Perceptron from a PerceptronLayer if there is more than
    // one layer.
    if (numLayers > 1 && randNumber < perceptronMutationRate) {
      // NOTE:  Cannot update the last layer, hence the -1. This is because the
      //        last layer represents the expected outputs, and that cannot
      //        change.
      final targetLayer = numberGenerator.nextInt(numLayers - 1);

      // Calculate the number of Genes in the target layer
      final numGenesInTargetLayer = child.dna.genes
          .where((gene) => gene.value.layer == targetLayer)
          .length;

      // Cannot remove from a layer that only has 1 perceptron
      if ((numGenesInTargetLayer == 1) || numberGenerator.nextBool) {
        child = await entityManipulationService.addPerceptronToLayer(
          entity: child,
          targetLayer: targetLayer,
        );
      } else {
        child = await entityManipulationService.removePerceptronFromLayer(
          entity: child,
          targetLayer: targetLayer,
        );
      }
    }

    return child;
  }
}
