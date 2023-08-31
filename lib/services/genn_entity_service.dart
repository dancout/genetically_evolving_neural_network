import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:genetically_evolving_neural_network/services/genn_fitness_service.dart';
import 'package:genetically_evolving_neural_network/services/genn_gene_service.dart';
import 'package:genetically_evolving_neural_network/services/perceptron_layer_mutation_service.dart';

class GENNEntityService extends EntityService<GENNPerceptron> {
  GENNEntityService({
    required this.layerMutationRate,
    required this.perceptronMutationRate,
    required super.dnaService,
    required GENNFitnessService fitnessService,
    required super.geneMutationService,
    required super.trackParents,
    super.random,
    PerceptronLayerMutationService? perceptronLayerMutationService,
  }) : super(
          fitnessService: fitnessService,
        ) {
    this.perceptronLayerMutationService = perceptronLayerMutationService ??
        PerceptronLayerMutationService(
          fitnessService: fitnessService,
          // TODO: Make this cast prettier or fix it otherwise
          geneService: geneMutationService.geneService as GENNGeneService,
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

    if (randNumber > layerMutationRate) {
      late Entity<GENNPerceptron> newChild;
      // Add or remove layer!
      if (random.nextBool()) {
        // TODO: Pick which layer more elegantly!
        const duplicationLayer = 0;

        final duplicatedPerceptrons =
            perceptronLayerMutationService.duplicatePerceptrons(
          perceptrons: child.dna.genes
              .where((gene) => gene.value.layer == duplicationLayer)
              .map((gene) => gene.value)
              .toList(),
        );
        // add layer
        newChild = perceptronLayerMutationService.addPerceptronLayer(
          entity: child,
          duplicatedPerceptrons: duplicatedPerceptrons,
        );
      } else {
        // TODO: Pick which layer more elegantly!
        const removalLayer = 1; // Can't remove the first input layer!

        // remove layer
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
      if (random.nextBool()) {
        // TODO: Pick a layer more elegantly

        const targetLayer = 1;

        perceptronLayerMutationService.addPerceptronToLayer(
          entity: child,
          targetLayer: targetLayer,
        );
      }
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
