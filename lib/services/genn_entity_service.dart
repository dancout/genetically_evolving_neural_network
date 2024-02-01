part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Used for creating new [GENNEntity] objects.
class GENNEntityService extends EntityService<GENNPerceptron> {
  /// Used for creating new [GENNEntity] objects.
  GENNEntityService({
    required super.dnaService,
    required super.fitnessService,
    required super.geneMutationService,
    @visibleForTesting super.crossoverService,
    required this.perceptronLayerMutationService,
    required super.entityParentManinpulator,
    required this.gennEntityServiceHelper,
    @visibleForTesting
    @visibleForTesting
    Future<Entity<GENNPerceptron>> Function({
      required List<Entity<GENNPerceptron>> parents,
      required int wave,
    })? superDotCrossover,
  }) {
    this.superDotCrossover = superDotCrossover ?? super.crossOver;
  }

  /// Assists with updating the [GENNPerceptron] objects or
  /// [GENNPerceptronLayer] objects within a [GENNEntity].
  final GENNEntityServiceHelper gennEntityServiceHelper;

  /// Used for mutating Perceptron Layers on the Entities.
  late final PerceptronLayerMutationService perceptronLayerMutationService;

  /// Represents the super.crossover function call.
  ///
  /// This is available so that we can mock this super call, skipping the super
  /// logic that we are not looking to test within this service.
  @visibleForTesting
  late final Future<Entity<GENNPerceptron>> Function({
    required List<Entity<GENNPerceptron>> parents,
    required int wave,
  }) superDotCrossover;

  @override
  Future<GENNEntity> crossOver({
    required List<Entity<GENNPerceptron>> parents,
    required int wave,
  }) async {
    // Generate an Entity from the super class.
    final superCrossoverEntity = await superDotCrossover(
      parents: parents,
      wave: wave,
    );
    // Convert the Entity into a GENNEntity
    final GENNEntity child = GENNEntity.fromEntity(
      entity: superCrossoverEntity,
    );

    // Potentially add or remove a Perceptron Layer within the GENNEntity.
    // child = await gennEntityServiceHelper.mutatePerceptronLayersWithinEntity(
    final mutatedLayersChild =
        await gennEntityServiceHelper.mutatePerceptronLayersWithinEntity(
      child: child,
    );

    // Potentially mutate a perceptron within the GENNEntity.
    final mutatedPerceptronsChild =
        await gennEntityServiceHelper.mutatePerceptronsWithinLayer(
      child: mutatedLayersChild,
    );

    return mutatedPerceptronsChild;
  }
}
