part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Responsible for manipulating [GENNEntity] objects;
class EntityManipulationService {
  /// Responsible for manipulating [GENNEntity] objects;
  EntityManipulationService({
    @visibleForTesting
    EntityManipulationServiceAdditionHelper?
        entitymanipulationServiceAdditionHelper,
    required this.numOutputs,
    required this.dnaManipulationService,
    required this.perceptronLayerAlignmentHelper,
    required this.fitnessService,
    Random? random,
    NumberGenerator? numberGenerator,
  })  : entityManipulationServiceAdditionHelper =
            entitymanipulationServiceAdditionHelper ??
                EntityManipulationServiceAdditionHelper(
                  fitnessService: fitnessService,
                ),
        numberGenerator = numberGenerator ??
            NumberGenerator(
              random: random ?? Random(),
            );

  /// Assists with adding a PerceptronLayer to the [GENNEntity] object.
  final EntityManipulationServiceAdditionHelper
      entityManipulationServiceAdditionHelper;

  /// The number of expected outputs for this NeuralNetwork
  final int numOutputs;

  /// Assists with updating the number of perceptrons within a Perceptron Layer.
  final PerceptronLayerAlignmentHelper perceptronLayerAlignmentHelper;

  /// Assists with adding and removing Genes from DNA.
  DNAManipulationService dnaManipulationService;

  /// Used to calculate the fitness score of an entity.
  final GENNFitnessService fitnessService;

  /// Used to generate random numbers and bools.
  final NumberGenerator numberGenerator;

  /// Returns a copy of the given [entity] with the given [targetLayer]
  /// PerceptronLayer duplicated.
  Future<GENNEntity> duplicatePerceptronLayerWithinEntity({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    // Extract the target PeceptronLayer on the entity
    final targetPerceptronLayer = GENNPerceptronLayer(
      perceptrons: entity.dna.genes
          .where((gennGene) => gennGene.value.layer == targetLayer)
          .map((gennGene) => gennGene.value)
          .toList(),
    );

    // Duplicate the target PerceptronLayer
    final duplicatedPerceptronLayer =
        entityManipulationServiceAdditionHelper.duplicatePerceptronLayer(
      gennPerceptronLayer: targetPerceptronLayer,
    );

    // Add PerceptronLayer into Entity
    entity = await entityManipulationServiceAdditionHelper
        .addPerceptronLayerToEntity(
      entity: entity,
      perceptronLayer: duplicatedPerceptronLayer,
    );

    return entity;
  }

  /// Returns a copy of the given [entity] after removing the [PerceptronLayer]
  /// represented by [targetLayer].
  Future<GENNEntity> removePerceptronLayerFromEntity({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    // Determine if we are working with the last Perceptron Layer within an
    // Entity.
    final bool isLastLayer = targetLayer == entity.maxLayerNum;

    // Grab the genes from the given Entity
    final gennGenes = entity.dna.genes;

    final numWeightsOfTargetLayer = entity.dna.genes
        .firstWhere((gennGene) => gennGene.value.layer == targetLayer)
        .value
        .weights
        .length;

    // Remove all genes from targetLayer
    gennGenes.removeWhere((gene) => gene.value.layer == targetLayer);

    // Decrement all layers after targetLayer
    final genesAfterRemoval = gennGenes.map(
      (gennGene) {
        if (gennGene.value.layer > targetLayer) {
          return gennGene.copyWith(
            value: gennGene.value.copyWith(layer: gennGene.value.layer - 1),
          );
        }
        return gennGene;
      },
    );

    // Update the weights for the genes now currently in the targetLayer
    // position. This is necessary because the number of perceptrons may not
    // have remained consistent from the previous layer to the target layer
    // after the removal.
    final genesWithUpdatedWeights = genesAfterRemoval.map((gene) {
      if (gene.value.layer == targetLayer) {
        final newWeights = List.generate(
          numWeightsOfTargetLayer,
          (_) => numberGenerator.randomNegOneToPosOne,
        );

        // Return the updated Gene within the targetLayer
        return gene.copyWith(
          value: gene.value.copyWith(weights: newWeights),
        );
      }
      // Return the unchanged Gene
      return gene;
    }).toList();

    // Declare the dna to be updated
    var updatedDNA = GENNDNA(genes: genesWithUpdatedWeights);

    // Create a copy of this entity with the new DNA
    var copiedEntityNewDna = entity.copyWith(dna: updatedDNA);

    // Check if we were working with the last layer.
    if (isLastLayer) {
      // If so, we need to ensure that there are the correct number of
      // perceptrons in the output layer.
      copiedEntityNewDna =
          await perceptronLayerAlignmentHelper.alignGenesWithinLayer(
        entity: copiedEntityNewDna,
        targetLayer: copiedEntityNewDna.maxLayerNum,
        targetGeneNum: numOutputs,
      );

      updatedDNA = copiedEntityNewDna.dna;
    }

    // Declare the updated fitness score from the updated DNA.
    final updatedFitnessScore =
        await fitnessService.calculateScore(dna: updatedDNA);

    // Return a copy of the original Entity with updated DNA and an updated
    // Fitness Score.
    return entity.copyWith(
      dna: updatedDNA,
      fitnessScore: updatedFitnessScore,
    );
  }

  /// Removes a [GENNPerceptron] from the given [entity] from the [targetLayer].
  Future<GENNEntity> removePerceptronFromLayer({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    // Declare the updated DNA object
    final updatedDNA = dnaManipulationService.removePerceptronFromDNA(
      dna: entity.dna,
      targetLayer: targetLayer,
    );
    // Calculate the updated fitness score based on the updated DNA
    final updatedFitnessScore =
        await fitnessService.calculateScore(dna: updatedDNA);

    // Return a copied version of the original Entity with updated DNA and an
    // updated Fitness Score.
    return entity.copyWith(
      dna: updatedDNA,
      fitnessScore: updatedFitnessScore,
    );
  }

  /// Adds a random [GENNPerceptron] to the given [entity] at the [targetLayer].
  Future<GENNEntity> addPerceptronToLayer({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    // Add a perceptron to the entity
    final updatedDNA = dnaManipulationService.addPerceptronToDNA(
      dna: entity.dna,
      targetLayer: targetLayer,
    );

    // Recalculate the fitness score
    final updatedFitnessScore =
        await fitnessService.calculateScore(dna: updatedDNA);

    // Return a new, updated entity
    return entity.copyWith(
      dna: updatedDNA,
      fitnessScore: updatedFitnessScore,
    );
  }
}
