part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Responsible for ensuring the correct number of [GENNPerceptron] objects
/// exist within a [GENNPerceptronLayer].
class PerceptronLayerAlignmentHelper {
  /// Responsible for ensuring the correct number of [GENNPerceptron] objects
  /// exist within a [GENNPerceptronLayer].
  PerceptronLayerAlignmentHelper({
    required this.dnaManipulationService,
    required this.fitnessService,
  });

  /// Responsible for updating [GENNDNA] objects.
  final DNAManipulationService dnaManipulationService;

  /// Responsible for calculating the fitness score for a [GENNEntity].
  final GENNFitnessService fitnessService;

  /// Returns an updated [entity] that now has [targetGeneNum] genes within the
  /// PerceptronLayer matching [targetLayer].
  Future<GENNEntity> alignGenesWithinLayer({
    required GENNEntity entity,
    required int targetLayer,
    required int targetGeneNum,
  }) async {
    // Get how many current genes there are within the target layer.
    final genesWithinTargetLayer = entity.dna.genes
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
    var updatedDNA = entity.dna;

    // Add or Remove as many genes as necessary to match the targetGeneNum
    for (int i = 0; i < diff; i++) {
      // Store the updated GENNDNA after removing a perceptron
      updatedDNA = addOrRemovePerceptronFromDNA(
        dna: updatedDNA,
        targetLayer: targetLayer,
      );
    }

    // Declare the updated FitnessScore from your updated DNA
    final updatedFitnessScore = diff > 0
        ? await fitnessService.calculateScore(dna: updatedDNA)
        // No need to update fitness score, as nothing changed
        : null;

    // Update the entity with its updated DNA and updated Fitness Score.
    entity = entity.copyWith(
      dna: updatedDNA,
      fitnessScore: updatedFitnessScore,
    );

    // Return the potentially updated entity
    return entity;
  }
}
