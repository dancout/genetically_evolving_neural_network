part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNGeneMutationService extends GeneMutationService<GENNPerceptron> {
  GENNGeneMutationService({
    required super.trackMutatedWaves,
    required super.mutationRate,
    required this.gennGeneService,
    super.random,
  }) : super(geneService: gennGeneService);

  final GENNGeneService gennGeneService;
}
