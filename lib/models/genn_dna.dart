part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNDNA extends DNA<GENNPerceptron> {
  GENNDNA({
    required this.gennGenes,
  }) : super(
            genes: gennGenes
              // TODO: This works, but see if there is a more efficient way of
              /// doing this rather than sorting every time. Potentially by
              /// adding genes into the correct place within the list when you
              /// make them (so you don't have to sort later).
              ..sort(
                (a, b) => (a.value.layer > b.value.layer) ? 1 : -1,
              ));

  final List<GENNGene> gennGenes;

  factory GENNDNA.fromDNA({required DNA<GENNPerceptron> dna}) {
    final gennGenes = <GENNGene>[];

    for (var gene in dna.genes) {
      gennGenes.add(GENNGene.fromGene(gene: gene));
    }

    return GENNDNA(gennGenes: gennGenes);
  }
}
