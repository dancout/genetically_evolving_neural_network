part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Used for creating new [Entity] objects.
class GENNEntityService extends EntityService<GENNPerceptron> {
  /// Used for creating new [Entity] objects.
  GENNEntityService({
    // TODO: Verify that all these parameters are actually necessary.
    required this.layerMutationRate,
    required this.perceptronMutationRate,
    required super.dnaService,
    required GENNFitnessService fitnessService,
    required GENNGeneMutationService geneMutationService,
    required bool trackParents,
    int? generationsToTrack,
    @visibleForTesting super.crossoverService,
    NumberGenerator? numberGenerator,
    required this.perceptronLayerMutationService,
    @visibleForTesting
    EntityParentManinpulator<GENNPerceptron>? entityParentManinpulator,
  })  : numberGenerator = numberGenerator ?? NumberGenerator(),
        super(
          fitnessService: fitnessService,
          geneMutationService: geneMutationService,
          entityParentManinpulator: entityParentManinpulator ??
              EntityParentManinpulator<GENNPerceptron>(
                trackParents: trackParents,
                generationsToTrack: generationsToTrack,
              ),
        ) {
    // this.perceptronLayerMutationService = perceptronLayerMutationService ??
    //     // TODO: Does it make more sense to make this required to pass in? That
    //     /// way we do not have quite so many parameters?

    //     PerceptronLayerMutationService(
    //       fitnessService: fitnessService,
    //       gennGeneServiceHelper:
    //           geneMutationService.gennGeneService.gennGeneServiceHelper,
    //       perceptronLayerMutationServiceHelperRENAMEME:
    //           perceptronLayerMutationServiceHelperRENAMEME,
    //       layerPerceptronAlignmentHelper:
    //           // TODO: Should you be able to pass a value in for this?
    //           LayerPerceptronAlignmentHelper(
    //         perceptronLayerMutationServiceHelperRENAMEME:
    //             perceptronLayerMutationServiceHelperRENAMEME,
    //         fitnessService: fitnessService,
    //       ),
    //       numOutputs:
    //     );
  }

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

  @override
  Future<Entity<GENNPerceptron>> crossOver({
    required List<Entity<GENNPerceptron>> parents,
    required int wave,
  }) async {
    // Generate an Entity from the super class.
    final superCrossover = await super.crossOver(
      parents: parents,
      wave: wave,
    );
    // Convert the Entity into a GENNEntity
    GENNEntity child = GENNEntity.fromEntity(
      entity: superCrossover,
    );

    final randNumber = numberGenerator.nextDouble;
    final gennNN = GENNNeuralNetwork.fromGenes(genes: child.dna.genes);
    var numLayers = gennNN.numLayers;

    // Add or Remove PerceptronLayer from Entity if mutation condition met.
    if (randNumber < layerMutationRate) {
      // TODO: Could extract this logic out into a helper function for when
      /// layerMutationRate is triggered to make this class more easily
      /// testable.

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
        child = perceptronLayerMutationService.addPerceptronLayerToEntity(
          entity: child,
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
        child = await perceptronLayerMutationService
            .removePerceptronLayerFromEntity(
          entity: child,
          targetLayer: targetLayer,
        );
        // Decrement the number of Perceptron Layers
        numLayers--;
      }
    }

    // Add or Remove a Perceptron from a PerceptronLayer if there is more than
    // one layer.
    if (numLayers > 1 && randNumber < perceptronMutationRate) {
      // TODO: Could extract this logic out into a helper function for when
      /// perceptronMutationRate is triggered to make this class more easily
      /// testable.

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
        child = await perceptronLayerMutationService.addPerceptronToLayer(
          entity: child,
          targetLayer: targetLayer,
        );
      } else {
        child = await perceptronLayerMutationService.removePerceptronFromLayer(
          entity: child,
          targetLayer: targetLayer,
        );
      }
    }

    return child;
  }
}
