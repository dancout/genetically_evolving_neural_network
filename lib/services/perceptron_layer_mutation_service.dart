import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

class PerceptronLayerMutationService {
  /// Returns a [PerceptronLayer] that is duplicated from the input
  /// [perceptronLayer] with the weights adjusted so the [Perceptron] objects
  /// will only receive input from their adjacent, previous neighbor.
  /// TODO: Include example in this doc.
  List<GENNPerceptron> duplicatePerceptrons({
    required List<GENNPerceptron> perceptrons,
  }) {
    final perceptrons = <GENNPerceptron>[];

    for (int i = 0; i < perceptrons.length; i++) {
      // Set all weights to 0 so they ignore input
      final weights =
          List<double>.generate(perceptrons[i].weights.length, (index) => 0.0);

      // Set this perceptron's adjacent, previous weight to its existing value.
      // This will effectively pass through the previous perceptron's value
      // forward.
      weights[i] = perceptrons[i].weights[i];

      perceptrons.add(
        GENNPerceptron(
          bias: perceptrons[i].bias,
          threshold: perceptrons[i].threshold,
          weights: weights,
          layer: perceptrons[i].layer + 1,
        ),
      );
    }

    return perceptrons;
  }

  Entity<GENNPerceptron> addPerceptronLayer({
    required Entity<GENNPerceptron> entity,
    required List<GENNPerceptron> duplicatedPerceptrons,
  }) {
    // TODO: Assert all the duplicated perceptrons have the same layer?

    final duplicationLayer = duplicatedPerceptrons.first.layer - 1;

    // Increment all layers after duplicationLayer
    final genes = entity.dna.genes.map((gene) {
      if (gene.value.layer > duplicationLayer) {
        return Gene(
          value: gene.value.copyWith(layer: gene.value.layer + 1),
        );
      }
      return gene;
    }).toList();

    // Add duplicated layer to genes
    genes.addAll(
      duplicatedPerceptrons
          .map((perceptron) => Gene(value: perceptron))
          .toList(),
    );

    return Entity(
      dna: DNA(genes: genes),
      fitnessScore: entity.fitnessScore,
    );
  }
}
