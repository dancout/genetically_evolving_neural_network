part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Crosses over parents to create a child.
class GENNCrossoverService extends CrossoverService<GENNPerceptron> {
  /// Crosses over parents to create a child.
  GENNCrossoverService({
    required super.geneMutationService,
    required this.gennCrossoverServiceAlignmentHelper,
    super.random,
    NumberGenerator? numberGenerator,
  });

  // TODO: Documentation for all values.

  late final GENNCrossoverServiceAlignmentHelper
      gennCrossoverServiceAlignmentHelper;

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
