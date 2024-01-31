part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Mutates the Perceptron Layers within a Neural Network.
class PerceptronLayerMutationService {
  /// Mutates the Perceptron Layers within a Neural Network.
  PerceptronLayerMutationService({
    required this.numOutputs,
    required this.dnaManipulationService,
    required this.layerPerceptronAlignmentHelper,
    required this.fitnessService,
    Random? random,
    NumberGenerator? numberGenerator,
  }) : numberGenerator = numberGenerator ??
            NumberGenerator(
              random: random ?? Random(),
            );

  /// The number of expected outputs for this NeuralNetwork
  final int numOutputs;

  /// Assists with updating the number of perceptrons within a Perceptron Layer.
  final LayerPerceptronAlignmentHelper layerPerceptronAlignmentHelper;

  /// Assists with adding and removing Genes from DNA.
  DNAManipulationService dnaManipulationService;

  /// Used to calculate the fitness score of an entity.
  final GENNFitnessService fitnessService;

  /// Used to generate random numbers and bools.
  final NumberGenerator numberGenerator;

  /// Returns a [GENNPerceptronLayer] that is duplicated from the input
  /// [gennPerceptronLayer] with the weights adjusted so the [GENNPerceptron]
  /// objects will only receive input from their adjacent, previous neighbor.
  GENNPerceptronLayer duplicatePerceptronLayer({
    required GENNPerceptronLayer gennPerceptronLayer,
  }) {
    final duplicatedPerceptrons = <GENNPerceptron>[];

    final perceptrons = gennPerceptronLayer.perceptrons;
    for (int i = 0; i < perceptrons.length; i++) {
      // Set all weights to 0 so they ignore input
      final weights = List<double>.generate(perceptrons.length, (index) => 0.0);

      // Set this perceptron's adjacent, previous weight to 1.0. This will
      // effectively pass through the previous perceptron's value forward.
      weights[i] = 1.0;

      duplicatedPerceptrons.add(
        GENNPerceptron(
          bias: perceptrons[i].bias,
          threshold: perceptrons[i].threshold,
          weights: weights,
          layer: perceptrons[i].layer + 1,
        ),
      );
    }

    return GENNPerceptronLayer(perceptrons: duplicatedPerceptrons);
  }

  // TODO: Consider breaking off another class, like EntityMutationService, that
  /// will house all the functions that return an Entity, and this class will be
  /// only for the PerceptronLayer returning functions.

  /// Returns a copy of the given [entity] with the given [perceptronLayer]
  /// inserted.
  GENNEntity addPerceptronLayerToEntity({
    required GENNEntity entity,
    required GENNPerceptronLayer perceptronLayer,
  }) {
    final duplicationLayer = perceptronLayer.perceptrons.first.layer - 1;

    // Increment all layers after duplicationLayer
    final genes = entity.dna.genes.map((gene) {
      if (gene.value.layer > duplicationLayer) {
        return gene.copyWith(
          value: gene.value.copyWith(layer: gene.value.layer + 1),
        );
      }
      return gene;
    }).toList();

    // Add duplicated layer to genes
    genes.addAll(
      perceptronLayer.perceptrons.map(
        (perceptron) => GENNGene(
          value: perceptron,
        ),
      ),
    );

    return entity.copyWith(
      dna: GENNDNA(genes: genes),
    );
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

    // TODO: Do we need to be creating a brand new list here, or is it just an
    // inefficiency?
    // Grab the genes from the given Entity
    final gennGenes = List<GENNGene>.from(entity.dna.genes);

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
          await layerPerceptronAlignmentHelper.alignGenesWithinLayer(
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
    final updatedDNA = dnaManipulationService.addPerceptronToDNA(
      dna: entity.dna,
      targetLayer: targetLayer,
    );
    final fitnessScore = await fitnessService.calculateScore(dna: updatedDNA);
    return entity.copyWith(
      dna: updatedDNA,
      fitnessScore: fitnessScore,
    );
  }
}
