import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_service.dart';

class GENNGeneMutationService extends GeneMutationService<GENNPerceptron> {
  GENNGeneMutationService({
    required super.trackMutatedWaves,
    required super.mutationRate,
    required this.gennGeneService,
    super.random,
  }) : super(geneService: gennGeneService);

  final GENNGeneService gennGeneService;
}
