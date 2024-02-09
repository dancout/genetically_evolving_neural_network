part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class is used to manipulate and return new copies of [GENNDNA].
class DNAManipulationService {
  /// This class is used to manipulate and return new copies of [GENNDNA].
  DNAManipulationService({
    required this.gennGeneServiceHelper,
    Random? random,
    NumberGenerator? numberGenerator,
  }) : numberGenerator = numberGenerator ??
            NumberGenerator(
              random: random ?? Random(),
            );

  /// Used to generate a random [GENNPerceptron].
  final GennGeneServiceHelper gennGeneServiceHelper;

  /// Used to generate random numbers and bools.
  final NumberGenerator numberGenerator;

  /// Adds a random perceptron to the [targetLayer] of the incoming [dna] and
  /// returns a new [GENNDNA] object.
  GENNDNA addPerceptronToDNA({
    required GENNDNA dna,
    required int targetLayer,
  }) {
    final genes = List<GENNGene>.from(dna.genes);

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

    return GENNDNA(genes: genes);
  }

  /// Removes a random perceptron from within the [targetLayer] of the incoming
  /// [dna] and returns an new [GENNDNA] object.
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

    // Declare the genes from the incoming DNA.
    var genes = List<GENNGene>.from(dna.genes);

    // Declare the list of genes within the targetLayer.
    final targetLayerGenes =
        genes.where((gene) => gene.value.layer == targetLayer).toList();

    // Declare a random index, representing the perceptron to remove.
    final randIndex = numberGenerator.nextInt(targetLayerGenes.length);

    // Declare the target Perceptron to remove.
    final targetPerceptron = targetLayerGenes[randIndex];

    // Remove the target perceptron.
    genes.remove(targetPerceptron);

    // Update the weights of the existing genes list to account for the removed
    // gene.
    genes = genes.map((gene) {
      // Check if the gene is in the layer after the target layer, because the
      // weights point backwards.
      if (gene.value.layer == targetLayer + 1) {
        final weights = List<double>.from(gene.value.weights);
        // Remove the weight connected to the removed perceptron
        weights.removeAt(randIndex);

        // Return the gene with it's updated weights
        return gene.copyWith(
          value: gene.value.copyWith(weights: weights),
        );
      }
      // Return the unchanged gene
      return gene;
    }).toList();

    return GENNDNA(genes: genes);
  }
}
