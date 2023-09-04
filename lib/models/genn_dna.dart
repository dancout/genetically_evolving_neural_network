import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_gene.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

class GENNDNA extends DNA<GENNPerceptron> {
  const GENNDNA({
    required this.gennGenes,
  }) : super(genes: gennGenes);

  final List<GENNGene> gennGenes;

  factory GENNDNA.fromDNA({required DNA<GENNPerceptron> dna}) {
    final gennGenes = <GENNGene>[];

    for (var gene in dna.genes) {
      gennGenes.add(GENNGene.fromGene(gene: gene));
    }

    return GENNDNA(gennGenes: gennGenes);
  }
}
