import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_service.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

class PerceptronLayerMutationService {
  const PerceptronLayerMutationService({
    required this.geneService,
    required this.fitnessService,
  });
  final GENNFitnessService fitnessService;
  final GENNGeneService geneService;

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

  Future<Entity<GENNPerceptron>> addPerceptronToLayer({
    required Entity<GENNPerceptron> entity,
    required targetLayer,
  }) async {
    assert(
        targetLayer > 0, 'Cannot add Perceptrons to the initial input layer');
    // TODO: Does this need to be List.from so we're not editing the *actual*
    /// list in place? OR, would that be a better idea for efficiency?
    final genes = entity.dna.genes;

    final numWeights =
        genes.where((gene) => gene.value.layer == targetLayer - 1).length;

    genes.add(
      Gene(
        value: geneService.randomPerceptron(
          numWeights: numWeights,
          layer: targetLayer,
        ),
      ),
    );

    for (int i = 0; i < genes.length; i++) {
      if (genes[i].value.layer == targetLayer + 1) {
        final perceptron = genes[i].value;

        final weights = perceptron.weights;
        weights.add(geneService.randomNegOneToPosOne());

        genes[i] = Gene(value: perceptron.copyWith(weights: weights));
      }
    }

    final dna = DNA(genes: genes);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);
    return Entity(
      dna: dna,
      fitnessScore: fitnessScore,
    );
  }

  Future<Entity<GENNPerceptron>> removePerceptronFromLayer({
    required Entity<GENNPerceptron> entity,
    required GENNPerceptron perceptron,
  }) async {
    return entity;
  }
}
