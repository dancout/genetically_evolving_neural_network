import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

class GENNGeneMutationService extends GeneMutationService<GENNPerceptron> {
  GENNGeneMutationService({
    required super.trackMutatedWaves,
    required super.mutationRate,
    required super.geneService,
    super.random,
  });
}
