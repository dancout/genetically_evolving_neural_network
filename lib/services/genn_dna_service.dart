import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

class GENNDNAService extends DNAService<GENNPerceptron> {
  GENNDNAService({
    required super.numGenes,
    required super.geneMutationService,
  });
}
