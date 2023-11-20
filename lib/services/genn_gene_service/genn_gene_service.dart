part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class is responsible for mutating and creating random Genes.
class GENNGeneService extends GeneService<GENNPerceptron> {
  GENNGeneService({
    required this.numInitialInputs,
    @visibleForTesting GennGeneServiceHelper? gennGeneServiceHelper,
    Random? random,
  }) : gennGeneServiceHelper = gennGeneServiceHelper ??
            GennGeneServiceHelper(
              random: random,
            );

  /// Used to assist this class with overridden methods.
  // TODO: Do we need this to be @visibleForTesting from here so that a user
  /// cannot access it through the GENNGeneService?
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

    return gennGeneServiceHelper.mutatePerceptron(perceptron: gennPerceptron);
  }
}
