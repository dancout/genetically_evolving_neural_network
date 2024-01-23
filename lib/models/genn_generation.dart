part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [GeneticEvolution.Generation].
class GENNGeneration extends Generation<GENNPerceptron> {
  /// An extension of [GeneticEvolution.Generation].
  const GENNGeneration({
    required super.wave,
    required GENNPopulation population,
  })  : _gennPopulation = population,
        super(population: population);

  final GENNPopulation _gennPopulation;

  /// Returns a [GENNGeneration] created from the input
  /// [GeneticEvolution.Generation] object.
  factory GENNGeneration.fromGeneration({
    required Generation<GENNPerceptron> generation,
  }) {
    return GENNGeneration(
      wave: generation.wave,
      population: GENNPopulation.fromPopulation(
        population: generation.population,
      ),
    );
  }

  @override
  GENNPopulation get population => _gennPopulation;

  @override
  List<Object?> get props => [
        ...super.props,
        _gennPopulation,
      ];
}
