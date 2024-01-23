part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNCrossoverServiceAlignmentHelper {
  GENNCrossoverServiceAlignmentHelper({
    required this.numOutputs,
    required this.perceptronLayerMutationService,
    GENNCrossoverServiceHelper? gennCrossoverServiceHelper,
    GENNCrossoverServiceAlignmentPerceptronHelper?
        gennCrossoverServiceAlignmentPerceptronHelper,
    NumberGenerator? numberGenerator,
  }) {
    final myGennCrossoverServiceHelper = gennCrossoverServiceHelper ??
        GENNCrossoverServiceHelper(
          numberGenerator: numberGenerator,
        );
    this.gennCrossoverServiceAlignmentPerceptronHelper =
        gennCrossoverServiceAlignmentPerceptronHelper ??
            GENNCrossoverServiceAlignmentPerceptronHelper(
              perceptronLayerMutationService: perceptronLayerMutationService,
              gennCrossoverServiceHelper: myGennCrossoverServiceHelper,
            );
  }

  late final GENNCrossoverServiceAlignmentPerceptronHelper
      gennCrossoverServiceAlignmentPerceptronHelper;

  /// The number of expected outputs for this NeuralNetwork
  final int numOutputs;

  /// Used to mutate the [GENNPerceptronLayer]s.
  final PerceptronLayerMutationService perceptronLayerMutationService;

  Future<List<GENNEntity>> alignNumLayersForParents({
    required List<GENNEntity> parents,
  }) async {
    final copiedParents = List<GENNEntity>.from(parents);

    int maxLayerNum = gennCrossoverServiceAlignmentPerceptronHelper
        .gennCrossoverServiceHelper
        .maxLayerNum(
      parents: copiedParents,
    );

    int minLayerNum = gennCrossoverServiceAlignmentPerceptronHelper
        .gennCrossoverServiceHelper
        .minLayerNum(
      maxLayerNum: maxLayerNum,
      parents: copiedParents,
    );

    // Make the maxLayerNum and minLayerNum match
    final targetNumLayers = gennCrossoverServiceAlignmentPerceptronHelper
        .gennCrossoverServiceHelper
        .alignMinAndMaxValues(
      maxValue: maxLayerNum,
      minValue: minLayerNum,
    );

    // Cycle through copiedParents
    for (int i = 0; i < copiedParents.length; i++) {
      // If the numbers of layers does not match, then make them match.
      if (copiedParents[i].maxLayerNum != targetNumLayers) {
        copiedParents[i] = await gennCrossoverServiceAlignmentPerceptronHelper
            .alignPerceptronLayersWithinEntity(
          gennEntity: copiedParents[i],
          targetNumLayers: targetNumLayers,
        );
      }
    }

    return copiedParents;
  }

  Future<List<GENNEntity>> alignGenesWithinLayersForParents({
    required List<GENNEntity> parents,
  }) async {
    final copiedParents = List<GENNEntity>.from(parents);

    // Declare the number of layers expected in each copied parent. Note that we
    // are adding one because the maxLayerNum is 0 indexed.
    final numLayers = copiedParents.first.maxLayerNum + 1;

    for (var copiedParent in copiedParents) {
      assert(
        copiedParent.maxLayerNum == numLayers - 1,
        'All parents must have the same number of layers to align their Genes.',
      );
    }

    // Cycle through each PerceptronLayer
    for (int currLayer = 0; currLayer < numLayers; currLayer++) {
      final perceptronLayersForCurrLayer = <GENNPerceptronLayer>[];

      for (var copiedParent in copiedParents) {
        final perceptronLayerWithinParent = GENNPerceptronLayer(
          perceptrons: copiedParent.dna.genes
              .where((gennGene) => gennGene.value.layer == currLayer)
              .map((gene) => gene.value)
              .toList(),
        );

        perceptronLayersForCurrLayer.add(perceptronLayerWithinParent);
      }

      // Check if we are looking at the final layer in the NeuralNetwork.
      final isLastLayer = currLayer == numLayers - 1;

      // Get the target number of perceptrons for this current layer
      final targetNumPerceptrons = isLastLayer
          // If we are on the last layer, then we should use the constant number
          // of expected output values for this Neural Network.
          ? numOutputs
          // Otherwise, choose the number of outputs for this layer.
          : gennCrossoverServiceAlignmentPerceptronHelper
              .alignNumPerceptronsWithinLayer(
              perceptronLayers: perceptronLayersForCurrLayer,
            );

      // Cycle through each Copied Parent
      for (int x = 0; x < copiedParents.length; x++) {
        // Make the number of Genes within the current layer match the
        // targetNumPerceptrons.
        copiedParents[x] = await gennCrossoverServiceAlignmentPerceptronHelper
            .alignGenesWithinLayer(
          entity: copiedParents[x],
          targetLayer: currLayer,
          targetGeneNum: targetNumPerceptrons,
        );
      }
    }

    return copiedParents;
  }
}
