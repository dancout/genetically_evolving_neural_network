part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

// TODO: Documentation & reconsider class name
/// Maybe name it PerceptronLayerAlignmentHelper?

class LayerPerceptronAlignmentHelper {
  LayerPerceptronAlignmentHelper({
    required this.dnaManipulationService,
    required this.fitnessService,
  });

  final DNAManipulationService dnaManipulationService;

  final GENNFitnessService fitnessService;

  /// Returns an updated [entity] that now has [targetGeneNum] genes within the
  /// PerceptronLayer matching [targetLayer].
  Future<GENNEntity> alignGenesWithinLayer({
    required GENNEntity entity,
    required int targetLayer,
    required int targetGeneNum,
  }) async {
    // TODO: Is this copywith necessary?
    var updatedEntity = entity.copyWith();

    // Get how many current genes there are within the target layer.
    final genesWithinTargetLayer = updatedEntity.dna.genes
        .where((gennGene) => gennGene.value.layer == targetLayer)
        .length;

    // Declare the function to be used to update the entity's DNA. It will
    // either remove or add perceptrons.
    GENNDNA Function({
      required GENNDNA dna,
      required int targetLayer,
    }) addOrRemovePerceptronFromDNA = (genesWithinTargetLayer > targetGeneNum)
        // There are too many perceptrons
        ? dnaManipulationService.removePerceptronFromDNA
        // There are not enough perceptrons
        : dnaManipulationService.addPerceptronToDNA;

    // Calculate the absolute value difference between the actual number of
    // genes within this layer and the target.
    final diff = (genesWithinTargetLayer - targetGeneNum).abs();

    // Declare a copy of the updated Entity's DNA.
    var updatedDNA = updatedEntity.dna;

    // Add or Remove as many genes as necessary to match the targetGeneNum
    for (int i = 0; i < diff; i++) {
      // Store the updated GENNDNA after removing a perceptron
      updatedDNA = addOrRemovePerceptronFromDNA(
        dna: updatedDNA,
        targetLayer: targetLayer,
      );
    }

    // Declare the updated FitnessScore from your updated DNA
    final updatedFitnessScore =
        await fitnessService.calculateScore(dna: updatedDNA);

    // Update the entity with its updated DNA and updated Fitness Score.
    updatedEntity = updatedEntity.copyWith(
      dna: updatedDNA,
      fitnessScore: updatedFitnessScore,
    );

    // Return the potentially updated entity
    return updatedEntity;
  }
}
