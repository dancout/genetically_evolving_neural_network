part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Crosses over parents to create a child.
class GENNCrossoverService extends CrossoverService<GENNPerceptron> {
  /// Crosses over parents to create a child.
  GENNCrossoverService({
    /// Used to mutate the [GENNPerceptronLayer]s.
    required PerceptronLayerMutationService? perceptronLayerMutationService,
    required super.geneMutationService,
    required this.numOutputs,
    required this.layerPerceptronAlignmentHelper,
    GENNCrossoverServiceHelper? gennCrossoverServiceHelper,
    super.random,
    NumberGenerator? numberGenerator,
    GENNCrossoverServiceAlignmentHelper? gennCrossoverServiceAlignmentHelper,
  }) {
    if (gennCrossoverServiceAlignmentHelper != null) {
      this.gennCrossoverServiceAlignmentHelper =
          gennCrossoverServiceAlignmentHelper;
    } else {
      if (perceptronLayerMutationService != null) {
        this.gennCrossoverServiceAlignmentHelper =
            GENNCrossoverServiceAlignmentHelper(
          numOutputs: numOutputs,
          perceptronLayerMutationService: perceptronLayerMutationService,
          numberGenerator: numberGenerator,
          gennCrossoverServiceHelper: gennCrossoverServiceHelper,
          // TODO: We are only passing layerPerceptronAlignmentHelper in case
          /// gennCrossoverServiceAlignmentHelper was null. Should we make
          /// gennCrossoverServiceAlignmentHelper required?
          layerPerceptronAlignmentHelper: layerPerceptronAlignmentHelper,
        );
      } else {
        throw Exception(
          'Cannot have both null PerceptronLayerMutationService AND null '
          'GENNCrossoverServiceAlignmentHelper',
        );
      }
    }
  }

  /// The number of expected outputs for this NeuralNetwork
  final int numOutputs;

  // TODO: Documentation for all values.

  late final GENNCrossoverServiceAlignmentHelper
      gennCrossoverServiceAlignmentHelper;

  final LayerPerceptronAlignmentHelper layerPerceptronAlignmentHelper;

  @override
  Future<List<Gene<GENNPerceptron>>> crossover({
    required List<Entity<GENNPerceptron>> parents,
    required int wave,
  }) async {
    // Convert the Entity<T> parents into GENNEntity objects.
    var gennParents =
        parents.map((parent) => GENNEntity.fromEntity(entity: parent)).toList();

    // Make the PerceptronLayers match up across all parents
    gennParents =
        await gennCrossoverServiceAlignmentHelper.alignNumLayersForParents(
      parents: gennParents,
    );

    // Make the Genes match up in each layer across all parents
    gennParents = await gennCrossoverServiceAlignmentHelper
        .alignGenesWithinLayersForParents(
      parents: gennParents,
    );

    // Finally, return the super.crossover with the updated parents.
    return super.crossover(
      parents: gennParents,
      wave: wave,
    );
  }
}
