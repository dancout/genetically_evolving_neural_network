part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Mutates the Perceptron Layers within a Neural Network.
class PerceptronLayerMutationService {
  /// Mutates the Perceptron Layers within a Neural Network.
  PerceptronLayerMutationService({
    required this.gennGeneServiceHelper,
    required this.fitnessService,
    Random? random,
    NumberGenerator? numberGenerator,
  }) : numberGenerator = numberGenerator ??
            NumberGenerator(
              random: random ?? Random(),
            );

  /// Used to calculate the fitness score of an entity.
  final GENNFitnessService fitnessService;

  /// Used to generate a random [GENNPerceptron].
  final GennGeneServiceHelper gennGeneServiceHelper;

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

  /// Inserts the given [perceptronLayer] into the given [entity].
  GENNEntity addPerceptronLayer({
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

  /// Removed the PerceptronLayer represented by [targetLayer] from the input
  /// [entity].
  Future<GENNEntity> removePerceptronLayerFromEntity({
    required GENNEntity entity,
    required int targetLayer,
    // TODO: Should this be what we pass in? Also, should probs be on the class
    /// object above.
    required GENNCrossoverServiceAlignmentHelper
        gENNCrossoverServiceAlignmentHelper,
  }) async {
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
    final dna = GENNDNA(genes: genesWithUpdatedWeights);

    // Create a copy of this entity with the new DNA
    final copiedEntityNewDna = entity.copyWith(dna: dna);

    // TODO: Calling alignGenesWithinLayersForParents is really inefficient
    /// because we are building out EVERY perceptron layer from scratch and only
    /// ever updating the last one (output layer). It might be better to make
    /// the alignGenesWithinLayer call on ONLY the final layer AND only if the
    /// [targetLayer] == entity.maxLayerNum.
    // Create a new entity that has the correct number of genes in the output
    // layer.
    final genesAlignedEntityNewDna = (await gENNCrossoverServiceAlignmentHelper
            // TODO: This alignGenesWithinLayersForParents should come from
            /// somewhere better that is more testable and doesn't have
            /// circular dependencies
            .alignGenesWithinLayersForParents(
      parents: [copiedEntityNewDna],
    ))
        .first;

    // Declare the updated DNA after aligning genes in the final layer
    final updatedDna = genesAlignedEntityNewDna.dna;

    // Declare the updated fitness score from the updated DNA.
    final updatedFitnessScore =
        await fitnessService.calculateScore(dna: updatedDna);

    // Return a copy of the original Entity with updated DNA and an updated
    // Fitness Score.
    return entity.copyWith(
      dna: updatedDna,
      fitnessScore: updatedFitnessScore,
    );
  }

  /// Adds a random [GENNPerceptron] to the given [entity] at the [targetLayer].
  Future<GENNEntity> addPerceptronToLayer({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    final genes = entity.dna.genes;

    // Grab the number of weights necessary from another gene from the
    // targetLayer.
    final numWeights = genes
        .firstWhere((gene) => gene.value.layer == targetLayer)
        .value
        .weights
        .length;

    genes.add(
      GENNGene(
        value: gennGeneServiceHelper.randomPerceptron(
          numWeights: numWeights,
          layer: targetLayer,
        ),
      ),
    );

    for (int i = 0; i < genes.length; i++) {
      if (genes[i].value.layer == targetLayer + 1) {
        final gene = genes[i];
        final perceptron = gene.value;

        final weights = List<double>.from(perceptron.weights);
        weights.add(numberGenerator.randomNegOneToPosOne);

        genes[i] = gene.copyWith(
          value: perceptron.copyWith(weights: weights),
        );
      }
    }

    final dna = GENNDNA(genes: genes);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);
    return entity.copyWith(
      dna: dna,
      fitnessScore: fitnessScore,
    );
  }

  /// Removes a [GENNPerceptron] from the given [entity] from the [targetLayer].
  Future<GENNEntity> removePerceptronFromLayer({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    // TODO: Should we consider this being put onto another class so it is more
    /// testable?
    // Declare the updated DNA object
    final updatedDNA = removePerceptronFromDNA(
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

  // TODO: Tests for this function.

  /// Removes a random perceptron from within the [targetLayer] of the incoming
  /// [dna] and returns an updated [GENNDNA] object.
  GENNDNA removePerceptronFromDNA({
    required GENNDNA dna,
    required int targetLayer,
  }) {
    assert(
      dna.genes
              .where((gennGene) => gennGene.value.layer == targetLayer)
              .length >
          1,
      'Cannot remove the only Perceptron from a given layer.',
    );

    var genes = dna.genes;

    final targetLayerGenes = List.from(
      genes.where((gene) => gene.value.layer == targetLayer).toList(),
    );

    final randIndex = numberGenerator.nextInt(targetLayerGenes.length);

    final targetPerceptron = targetLayerGenes[randIndex];

    genes.remove(targetPerceptron);

    genes = genes.map((gene) {
      if (gene.value.layer == targetLayer + 1) {
        final weights = List<double>.from(gene.value.weights);
        // Remove the weight connected to the removed perceptron
        weights.removeAt(randIndex);

        return gene.copyWith(
          value: gene.value.copyWith(weights: weights),
        );
      }
      return gene;
    }).toList();

    return GENNDNA(genes: genes);
  }
}
