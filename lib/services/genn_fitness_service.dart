part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [GeneticEvolution.FitnessService].
abstract class GENNFitnessService extends FitnessService<GENNPerceptron> {
  /// The internal scoring function used to calculate the fitness score of the
  /// input [neuralNetwork].
  ///
  /// This value is meant to be non-negative.
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  });

  @override
  double get nonZeroBias => 0.01;

  @override
  Future<double> scoringFunction({required DNA<GENNPerceptron> dna}) {
    // NOTE:  This is really just a wrapper function for the scoringFunction
    //        method used within the GeneticEvolution library. It is used so we
    //        can be stricter about using GENNDNA instead of
    //        DNA<GENNPerceptron>.

    // Declare the NeuralNetwork
    final neuralNetwork = GENNNeuralNetwork.fromGenes(
      genes: GENNDNA.fromDNA(dna: dna).genes,
    );

    return gennScoringFunction(neuralNetwork: neuralNetwork);
  }
}
