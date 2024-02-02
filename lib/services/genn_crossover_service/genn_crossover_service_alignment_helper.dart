part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Responsible for ensuring that there is the proper number of
/// [GENNPerceptronLayer] objects present within a [GENNEntity] as well as
/// [GENNPerceptron] objects within a [GENNPerceptronLayer].
class GENNCrossoverServiceAlignmentHelper {
  /// Responsible for ensuring that there is the proper number of
  /// [GENNPerceptronLayer] objects present within a [GENNEntity] as well as
  /// [GENNPerceptron] objects within a [GENNPerceptronLayer].
  GENNCrossoverServiceAlignmentHelper({
    required this.numOutputs,
    // TODO: Should this be required? Re-evaluate all the parameters here if
    /// they're necessary.
    required this.perceptronLayerMutationService,
    required this.layerPerceptronAlignmentHelper,
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

  /// Updates the [GENNPerceptron] and [GENNPerceptronLayer] objects within a
  /// [GENNEntity].
  late final GENNCrossoverServiceAlignmentPerceptronHelper
      gennCrossoverServiceAlignmentPerceptronHelper;

  /// Updates the [GENNPerceptron] objects within a [GENNPerceptronLayer].
  final LayerPerceptronAlignmentHelper layerPerceptronAlignmentHelper;

  /// The number of expected outputs for this NeuralNetwork
  final int numOutputs;

  /// Used to mutate the [GENNPerceptronLayer]s.
  final PerceptronLayerMutationService perceptronLayerMutationService;

  /// Updates the incoming [parents] so that they have the same number of
  /// internal Perceptron Layers.
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

  /// Ensures the incoming [parents] all have the same number of Perceptrons
  /// (Genes) within each internal Perceptron Layer.
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
        copiedParents[x] =
            await layerPerceptronAlignmentHelper.alignGenesWithinLayer(
          entity: copiedParents[x],
          targetLayer: currLayer,
          targetGeneNum: targetNumPerceptrons,
        );
      }
    }

    return copiedParents;
  }
}
