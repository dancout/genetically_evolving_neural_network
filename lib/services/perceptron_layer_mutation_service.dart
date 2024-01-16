part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Mutates the Perceptron Layers within a Neural Network.
class PerceptronLayerMutationService {
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
  /// TODO: Include example in this doc.
  GENNPerceptronLayer duplicatePerceptronLayer({
    required GENNPerceptronLayer gennPerceptronLayer,
  }) {
    final duplicatedPerceptrons = <GENNPerceptron>[];

    final perceptrons = gennPerceptronLayer.gennPerceptrons;
    for (int i = 0; i < perceptrons.length; i++) {
      // Set all weights to 0 so they ignore input
      final weights = List<double>.generate(perceptrons.length, (index) => 0.0);

      // Set this perceptron's adjacent, previous weight to 1.0. This will
      // effectively pass through the previous perceptron's value forward.
      // weights[i] = perceptrons[i].weights[i];
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

    return GENNPerceptronLayer(gennPerceptrons: duplicatedPerceptrons);
  }

  /// Inserts the given [perceptronLayer] into the given [entity].
  GENNEntity addPerceptronLayer({
    required GENNEntity entity,
    required GENNPerceptronLayer perceptronLayer,
  }) {
    final duplicationLayer = perceptronLayer.gennPerceptrons.first.layer - 1;

    // Increment all layers after duplicationLayer
    final genes = entity.gennDna.gennGenes.map((gene) {
      if (gene.value.layer > duplicationLayer) {
        return gene.copyWith(
          value: gene.value.copyWith(layer: gene.value.layer + 1),
        );
      }
      return gene;
    }).toList();

    // Add duplicated layer to genes
    genes.addAll(
      perceptronLayer.gennPerceptrons.map(
        (perceptron) => GENNGene(
          value: perceptron,
        ),
      ),
    );

    return entity.copyWith(
      dna: GENNDNA(gennGenes: genes),
    );
  }

  /// Removed the PerceptronLayer represented by [targetLayer] from the input
  /// [entity].
  Future<GENNEntity> removePerceptronLayerFromEntity({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    // Grab the genes from the given Entity
    final gennGenes = entity.gennDna.gennGenes;

    final numWeightsOfTargetLayer = entity.gennDna.gennGenes
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

    final dna = GENNDNA(gennGenes: genesWithUpdatedWeights);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);

    return entity.copyWith(
      dna: dna,
      fitnessScore: fitnessScore,
    );
  }

  /// Adds a random [GENNPerceptron] to the given [entity] at the [targetLayer].
  Future<GENNEntity> addPerceptronToLayer({
    required GENNEntity entity,
    required int targetLayer,
  }) async {
    // TODO: Do we need this assert? Or is it overkill and inefficient?
    assert(
      targetLayer < entity.maxLayerNum,
      'Cannot add Perceptrons to the last perceptron layer. '
      'This is the output layer and has a fixed number of perceptrons.',
    );

    final genes = entity.gennDna.gennGenes;

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

    final dna = GENNDNA(gennGenes: genes);
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
    // TODO: Do we need this assert, or should we remove for efficiency?
    assert(
      entity.gennDna.gennGenes
              .where((gennGene) => gennGene.value.layer == targetLayer)
              .length >
          1,
      'Cannot remove the only Perceptron from a given layer.',
    );

    var genes = entity.gennDna.gennGenes;

    final targetLayerGenes = List.from(
        genes.where((gene) => gene.value.layer == targetLayer).toList());

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

    final dna = GENNDNA(gennGenes: genes);
    final fitnessScore = await fitnessService.calculateScore(dna: dna);

    return entity.copyWith(
      dna: dna,
      fitnessScore: fitnessScore,
    );
  }
}
