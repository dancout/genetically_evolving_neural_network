part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Used for creating new [Entity] objects.
class GENNEntityService extends EntityService<GENNPerceptron> {
  GENNEntityService({
    required this.layerMutationRate,
    required this.perceptronMutationRate,
    required super.dnaService,
    required GENNFitnessService fitnessService,
    required GENNGeneMutationService geneMutationService,
    required super.trackParents,
    @visibleForTesting super.crossoverService,
    NumberGenerator? numberGenerator,
    // TODO: Should this be visibleForTesting?
    PerceptronLayerMutationService? perceptronLayerMutationService,
  })  : numberGenerator = numberGenerator ?? NumberGenerator(),
        super(
          fitnessService: fitnessService,
          geneMutationService: geneMutationService,
        ) {
    this.perceptronLayerMutationService = perceptronLayerMutationService ??
        PerceptronLayerMutationService(
          fitnessService: fitnessService,
          gennGeneServiceHelper:
              geneMutationService.gennGeneService.gennGeneServiceHelper,
        );
  }

  /// Used to generate random numbers and bools.
  final NumberGenerator numberGenerator;
  final double layerMutationRate;
  final double perceptronMutationRate;
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
    final gennNN = GENNNeuralNetwork.fromGenes(genes: child.gennDna.gennGenes);
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
          gennPerceptronLayer: gennNN.gennLayers[duplicationLayer],
        );

        // Add PerceptronLayer into Entity
        child = perceptronLayerMutationService.addPerceptronLayer(
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
      // NOTE:  Cannot update the last layer, hence the -1. This is because the
      //        last layer represents the expected outputs, and that cannot
      //        change.
      final targetLayer = numberGenerator.nextInt(numLayers - 1);

      // TODO: Could this be optimized? Looking at the GENNPerceptronLayer we
      /// could have access to the layer value immediately. But we'd have to
      /// build that object, which might also be inefficient.
      final numGenesInTargetLayer = child.gennDna.gennGenes
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
