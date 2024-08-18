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

    // TODO: What I want to do differently, is that we shouldn't have an X% chance that this *gene* will mutate, but maybe we should instead focus on there being a X% chance that *any feature* will mutate.
    /// What this means is that we should run through all possible mutation options, and do an X% chance check against each option.
    /// Steps:
    /// - Store the original "mutatationRate" in a secondary variable somewhere, called "originalMutationRate"
    /// - Update the mutationRate value in the config to be 1 (or 100%)
    ///     - This will force the mutateValue function to be run *every time* so that we can check against each *feature*, not just the genes
    /// - Forloop over every possible mutation option (bias + threshold + weights)
    ///     - Generate a random value
    ///     - If the random value is less than the "originalMutationRate", then call "mutateBasedOnSelectedOption" for that index
    /// NOTE: We might have to update how this is done, because "mutateBasedOnSelectedOption" returns an entire gene, not just that rand value
    ///
    /// OORRRRRRR - We could override the mutateGene call? To not have to deal with *every* gene now having *every* wave show "mutatedWave" or whatever

    // Return a new GENNPerceptron with its selected mutation
    return gennGeneServiceMutationHelper.mutateBasedOnSelectedOption(
        selectedOption, perceptron);
  }

  /// Creates a randomized [GENNPerceptron].
  GENNPerceptron randomPerceptron({
    required int numWeights,
    required int layer,
    bool randomizeWeights = true,
  }) {
    assert(
      numWeights > 0,
      'numWeights must be greater than 0 when creating a random Perceptron.',
    );

    // According to Tariq Rashid's book, "Make Your Own Neural Network", the
    // weights should range from -1/sqrt(numWeights) to 1/sqrt(numWeights).
    final weightShrinkingFactor = sqrt(numWeights);

    return GENNPerceptron(
      bias: numberGenerator.randomNegOneToPosOne,
      // TODO: This halved threshold is really only relevant if sigmoid is true. Otherwise, it should be open-ended without the division.
      threshold: (numberGenerator.nextDouble / 2.0) + 0.5,
      weights: List.generate(
        numWeights,
        (_) => randomizeWeights
            ? (numberGenerator.randomNegOneToPosOne / weightShrinkingFactor)
            // If we are not randomizing weights, assign them all as zero
            : 0.0,
      ),
      layer: layer,
    );
  }
}
