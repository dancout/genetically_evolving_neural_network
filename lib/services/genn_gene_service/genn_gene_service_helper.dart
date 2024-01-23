part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Houses the internal functions that mutate and generate new GENNPerceptrons.
class GennGeneServiceHelper {
  GennGeneServiceHelper({
    Random? random,
    NumberGenerator? numberGenerator,
    GennGeneServiceMutationHelper? gennGeneServiceMutationHelper,
  })  : numberGenerator = numberGenerator ?? NumberGenerator(),
        gennGeneServiceMutationHelper =
            gennGeneServiceMutationHelper ?? GennGeneServiceMutationHelper();

  /// Assists with the mutations on the GENNPerceptrons.
  final GennGeneServiceMutationHelper gennGeneServiceMutationHelper;

  /// Used to generate random numbers and bools.
  final NumberGenerator numberGenerator;

  /// Mutates the given [GENNPerceptron].
  GENNPerceptron mutatePerceptron({
    required GENNPerceptron perceptron,
  }) {
    // Select an option to mutate
    int selectedOption =
        gennGeneServiceMutationHelper.selectMutationOption(perceptron);

    // Return a new GENNPerceptron with its selected mutation
    return gennGeneServiceMutationHelper.mutateBasedOnSelectedOption(
        selectedOption, perceptron);
  }

  /// Creates a randomized [GENNPerceptron].
  GENNPerceptron randomPerceptron({
    required int numWeights,
    required int layer,
  }) {
    assert(
      numWeights > 0,
      'numWeights must be greater than 0 when creating a random Perceptron.',
    );

    return GENNPerceptron(
      bias: numberGenerator.randomNegOneToPosOne,
      threshold: numberGenerator.nextDouble,
      weights: List.generate(
          numWeights, (_) => numberGenerator.randomNegOneToPosOne),
      layer: layer,
    );
  }
}
