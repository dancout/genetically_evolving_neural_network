part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class is responsible for mutating and creating random Genes.
class GENNGeneService extends GeneService<GENNPerceptron> {
  GENNGeneService({
    required this.numInitialInputs,
    @visibleForTesting GennGeneServiceHelper? gennGeneServiceHelper,
    required this.originalMutationRate,
    Random? random,
  }) : 
  random = random ?? Random(),
  gennGeneServiceHelper = gennGeneServiceHelper ??
            GennGeneServiceHelper(
              random: random,
            );


    final Random random;
  final double originalMutationRate;
  // TODO: This should be included in the constructor for testing
    final GennGeneServiceMutationHelper gennGeneServiceMutationHelper = GennGeneServiceMutationHelper();

  /// Used to assist this class with overridden methods.
  @visibleForTesting
  final GennGeneServiceHelper gennGeneServiceHelper;

  /// Represents the number of initial inputs for creating a Random Gene.
  final int numInitialInputs;

  @override
  Gene<GENNPerceptron> randomGene() {
    const initialLayer = 0;

    return GENNGene(
      value: gennGeneServiceHelper.randomPerceptron(
        layer: initialLayer,
        numWeights: numInitialInputs,
      ),
    );
  }

  @override
  GENNPerceptron mutateValue({GENNPerceptron? value}) {
    final gennPerceptron = value;
    if (gennPerceptron == null) {
      throw Exception('Cannot mutate null GENNPerceptron.');
    }


  var currentGENNPerceptron = gennPerceptron.copyWith();

    // plus 2 for bias and threshold
    for(int i = 0; i < gennPerceptron.weights.length + 2; i++) {
      final randomValue = random.nextDouble();
      // print('i: $i');
      if (originalMutationRate > randomValue) {
        // print('found a new index to change: $i');
        currentGENNPerceptron = gennGeneServiceMutationHelper.mutateBasedOnSelectedOption(
        i, currentGENNPerceptron);
      }
    }

    // return gennGeneServiceHelper.mutatePerceptron(perceptron: gennPerceptron);
    return currentGENNPerceptron;
  }
}
