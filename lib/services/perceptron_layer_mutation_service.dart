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
      duplicatedPerceptrons.map((perceptron) {
        assert(
          perceptron.layer == duplicationLayer,
          'All duplicatedPerceptrons must have the same layer.',
        );
        return Gene(value: perceptron);
      }).toList(),
    );

    return Entity(
      dna: DNA(genes: genes),
      fitnessScore: entity.fitnessScore,
    );
  }

  Entity<GENNPerceptron> removePerceptronLayer({
    required Entity<GENNPerceptron> entity,
    required int removalLayer,
  }) {
    return entity;
    // TODO: Figure out what to do with the weights when a lyaer is removed
    /// Should we even be removing layers, or always adding on?
    // // Decrement all layers after removalLayer
    // final genes = entity.dna.genes.map((gene) {
    //   if (gene.value.layer > removalLayer) {
    //     return Gene(
    //       value: gene.value.copyWith(layer: gene.value.layer - 1),
    //     );
    //   }
    //   return gene;
    // }).toList();

    // // Remove layer from genes
    // genes.removeWhere((gene) => gene.value.layer == removalLayer);
  }
}
