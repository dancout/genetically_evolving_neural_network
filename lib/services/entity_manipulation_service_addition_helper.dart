part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Responsible for assisting with duplicating and adding [GENNPerceptronLayer]
/// objects within a [GENNEntity].
class EntityManipulationServiceAdditionHelper {
  /// Responsible for assisting with duplicating and adding
  /// [GENNPerceptronLayer] objects within a [GENNEntity].
  EntityManipulationServiceAdditionHelper({
    required this.fitnessService,
  });

  /// Used to calculate the fitness score of an entity.
  final GENNFitnessService fitnessService;

  /// Returns a copy of the given [entity] with the given [perceptronLayer]
  /// inserted.
  Future<GENNEntity> addPerceptronLayerToEntity({
    required GENNEntity entity,
    required GENNPerceptronLayer perceptronLayer,
  }) async {
    final duplicationLayer = perceptronLayer.perceptrons.first.layer - 1;

    // Increment all layers after duplicationLayer
    final genes = List<GENNGene>.from(entity.dna.genes.map((gene) {
      if (gene.value.layer > duplicationLayer) {
        return gene.copyWith(
          value: gene.value.copyWith(layer: gene.value.layer + 1),
        );
      }
      return gene;
    }).toList());

    // Add duplicated layer to genes
    genes.addAll(
      perceptronLayer.perceptrons.map(
        (perceptron) => GENNGene(
          value: perceptron,
        ),
      ),
    );

    final updatedFitnessScore = await fitnessService.calculateScore(
      dna: GENNDNA(genes: genes),
    );

    return entity.copyWith(
      dna: GENNDNA(genes: genes),
      fitnessScore: updatedFitnessScore,
    );
  }

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
}
