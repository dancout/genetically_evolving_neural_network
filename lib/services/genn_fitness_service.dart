import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_dna.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

abstract class GENNFitnessService extends FitnessService<GENNPerceptron> {
  Future<double> gennScoringFunction({required GENNDNA gennDna});

  @override
  Future<double> scoringFunction({required DNA<GENNPerceptron> dna}) {
    // NOTE:  This is really just a wrapper function for the scoringFunction
    //        method used within the GeneticEvolution library. It is used so we
    //        can be stricter about using GENNDNA instead of
    //        DNA<GENNPerceptron>.
    return gennScoringFunction(gennDna: dna as GENNDNA);
  }
}
