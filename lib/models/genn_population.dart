part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [GeneticEvolution.Population].
@JsonSerializable()
class GENNPopulation extends Population<GENNPerceptron> {
  /// An extension of [GeneticEvolution.Population].
  const GENNPopulation({
    required List<GENNEntity> entities,
    int Function(Entity a, Entity b)? sortingMethod,
  })  : _gennEntitys = entities,
        super(
          entities: entities,
          sortingMethod: sortingMethod ?? _fallbackSortMethod,
        );

  /// The [GENNEntity] objects populating this Population.
  final List<GENNEntity> _gennEntitys;

  @override
  List<GENNEntity> get entities => _gennEntitys;

  @override
  GENNEntity get topScoringEntity => GENNEntity.fromEntity(
        entity: super.topScoringEntity,
      );

  @override
  List<GENNEntity> get sortedEntities => List.from(_gennEntitys)
    ..sort(
      super.sortingMethod,
    );

  /// Returns a [GENNPopulation] created from the input [Population].
  factory GENNPopulation.fromPopulation({
    required Population<GENNPerceptron> population,
  }) {
    return GENNPopulation(
      entities: population.entities
          .map((e) => GENNEntity.fromEntity(entity: e))
          .toList(),
    );
  }
  @override
  List<Object?> get props => [
        ...super.props,
        _gennEntitys,
      ];

  // TODO: revisit this sorting method after the genetic_evolution changes have
  /// been made.
  @override
  @JsonKey(
    fromJson: Population.sortingMethodFromJson,
    toJson: Population.sortingMethodToJson,
  )
  int Function(Entity a, Entity b)? get sortingMethod => super.sortingMethod;

  /// Sorts [Entity] objects in order from highest fitness score to lowest.
  static int _fallbackSortMethod(Entity a, Entity b) =>
      b.fitnessScore.compareTo(a.fitnessScore);

  /// Converts the input [json] into a [GENNPopulation] object.
  factory GENNPopulation.fromJson(Map<String, dynamic> json) =>
      _$GENNPopulationFromJson(json);

  /// Converts the [GENNPopulation] object to JSON.
  @override
  Map<String, dynamic> toJson() => _$GENNPopulationToJson(this);
}
