import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

class GENNEntityService extends EntityService<GENNPerceptron> {
  GENNEntityService({
    required super.dnaService,
    required super.fitnessService,
    required super.geneMutationService,
    required super.trackParents,
    super.random,
  });

  @override
  Future<Entity<GENNPerceptron>> crossOver({
    required List<Entity<GENNPerceptron>> parents,
    required int wave,
  }) async {
    final child = await super.crossOver(
      parents: parents,
      wave: wave,
    );

    // Potentially add a new PerceptronLayer here

    final randNumber = random.nextDouble();

    // TODO: We probably shouldn't be using the mutationRate, but instead a
    /// PerceptronLayerMutationRate specifically for adding or removing layers.
    /// We should probably expect this to be lower than the mutationRate.
    if (randNumber > geneMutationService.mutationRate) {
      late Entity<GENNPerceptron> newChild;
      // Add or remove layer!
      if (random.nextBool()) {
        // add layer
        newChild = child;
      } else {
        // remove layer
        newChild = child;
      }
      return newChild;
    }

    // TODO: Consider doing the above adding/removing layer work from the
    /// PopulationService. This is already included in GeneticEvolution (so no
    /// changes necessary to the GeneticEvolution dependency). The downside is
    /// that we have to run through the created population and either change the
    /// entities in place or create a new population list, which feels
    /// inefficient.
    return child;
  }
}
