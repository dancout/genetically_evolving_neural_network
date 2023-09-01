import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_neural_network.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_mutation_service.dart';
import 'package:genetically_evolving_neural_network/services/perceptron_layer_mutation_service.dart';

class GENNEntityService extends EntityService<GENNPerceptron> {
  GENNEntityService({
    required this.layerMutationRate,
    required this.perceptronMutationRate,
    required super.dnaService,
    required GENNFitnessService fitnessService,
    required GENNGeneMutationService geneMutationService,
    required super.trackParents,
    super.random,
    PerceptronLayerMutationService? perceptronLayerMutationService,
  }) : super(
          fitnessService: fitnessService,
          geneMutationService: geneMutationService,
        ) {
    this.perceptronLayerMutationService = perceptronLayerMutationService ??
        PerceptronLayerMutationService(
          fitnessService: fitnessService,
          geneService: geneMutationService.gennGeneService,
        );
  }
  final double layerMutationRate;
  final double perceptronMutationRate;
  late final PerceptronLayerMutationService perceptronLayerMutationService;

  @override
  Future<Entity<GENNPerceptron>> crossOver({
    required List<Entity<GENNPerceptron>> parents,
    required int wave,
  }) async {
    final child = await super.crossOver(
      parents: parents,
      wave: wave,
    );

    final randNumber = random.nextDouble();

    final gennNN = GENNNeuralNetwork.fromGenes(genes: child.dna.genes);

    // Add or Remove PerceptronLayer from Entity if mutation condition met.
    if (randNumber > layerMutationRate) {
      // Declare the new Entity
      late Entity<GENNPerceptron> newChild;
      // NOTE: If there is only a single layer, then we cannot remove it, so we
      // must add to it.
      if (gennNN.numLayers == 1 || random.nextBool()) {
        // Randomly pick a layer to duplicate
        final duplicationLayer = random.nextInt(gennNN.numLayers);

        // Duplicate PerceptronLayer
        final duplicatedPerceptronLayer =
            perceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: gennNN.gennLayers[duplicationLayer],
        );

        // Add PerceptronLayer into Entity
        newChild = perceptronLayerMutationService.addPerceptronLayer(
          entity: child,
          perceptronLayer: duplicatedPerceptronLayer,
        );
      } else {
        // NOTE: Cannot remove last layer, hence the -1.
        final removalLayer = random.nextInt(gennNN.numLayers - 1);

        // Remove PerceptronLayer from Entity
        newChild = perceptronLayerMutationService.removePerceptronLayer(
          entity: child,
          removalLayer: removalLayer,
        );
      }
      return newChild;
    }

    // TODO: We should only get into this if block if there is more than 1 inputLayer!
    /// We could consider creating a NeuralNetwork above from the list of genes,
    /// and then we can use the built in NN functionality (like PerceptronLayer
    /// and numLayer) to make these calculations easier!
    if (randNumber > perceptronMutationRate) {
      late Entity<GENNPerceptron> newChild;
      if (random.nextBool()) {
        // TODO: Pick a layer more elegantly

        const targetLayer = 1;

        newChild = await perceptronLayerMutationService.addPerceptronToLayer(
          entity: child,
          targetLayer: targetLayer,
        );
      } else {
        // TODO: Implement removePerceptronFromLayer
        // newChild =
        //     await perceptronLayerMutationService.removePerceptronFromLayer(
        //   entity: child,
        //   perceptron: perceptron,
        // );
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
