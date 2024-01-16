part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [NeuralNetwork.DNA].
class GENNDNA extends DNA<GENNPerceptron> {
  GENNDNA({
    required this.gennGenes,
  }) : super(
            genes: gennGenes
              // Sort the genes by Perceptron layer for consistency.
              // NOTE:  This is necessary, otherwise perceptrons may be crossed
              //        over among different layers, which is unintentional.
              ..sort(
                (a, b) => (a.value.layer > b.value.layer) ? 1 : -1,
              ));

  final List<GENNGene> gennGenes;

  /// Returns a [GENNDNA] object created from the input [DNA].
  factory GENNDNA.fromDNA({required DNA<GENNPerceptron> dna}) {
    final gennGenes = <GENNGene>[];

    for (var gene in dna.genes) {
      gennGenes.add(GENNGene.fromGene(gene: gene));
    }

    return GENNDNA(gennGenes: gennGenes);
  }
}
