part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [GeneticEvolution.FitnessService].
abstract class GENNFitnessService extends FitnessService<GENNPerceptron> {
  GENNFitnessService({
    bool? sigmoid,
  }) : sigmoid = sigmoid ?? false, _guessService = ((sigmoid ?? false) ? GuessService(
              activationService: ActivationService(
              normalizationService: SigmoidNormalizationService(),
            )): null);

  final bool sigmoid;

  /// The internal scoring function used to calculate the fitness score of the
  /// input [neuralNetwork].
  ///
  /// This value is meant to be non-negative.
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  });

  final GuessService? _guessService;

  GuessService? get guessService => _guessService;

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
      guessService: sigmoid
          ? _guessService
          : null,
    );

    return gennScoringFunction(neuralNetwork: neuralNetwork);
  }
}

class SigmoidNormalizationService extends OutputNormalizationService {
  @override
  normalizeValue({
    required double value,
  }) {
    return  1 / (1 + exp(-value));
  }
}
