part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [GeneticEvolution.Entity]
@JsonSerializable()
class GENNEntity extends Entity<GENNPerceptron> {
  /// An extension of [GeneticEvolution.Entity]
  const GENNEntity({
    required GENNDNA dna,
    required super.fitnessScore,
    List<GENNEntity>? parents,
  })  : _gennDna = dna,
        _gennParents = parents,
        super(
          dna: dna,
          parents: parents,
        );

  final List<GENNEntity>? _gennParents;
  final GENNDNA _gennDna;

  /// The highest Layer value present within the [_gennDna]'s [gennGene] objects.
  int get maxLayerNum => _gennDna.genes.fold(
        0,
        (previousValue, gennGene) => (previousValue > gennGene.value.layer)
            ? previousValue
            : gennGene.value.layer,
      );

  /// Returns a [GENNEntity] object created from the input [Entity].
  factory GENNEntity.fromEntity({required Entity<GENNPerceptron> entity}) {
    List<GENNEntity>? gennParents;

    // Copy the parents of this Entity into the new GENNEntity
    final parents = entity.parents;
    if (parents != null) {
      gennParents = <GENNEntity>[];
      for (var parent in parents) {
        gennParents.add(GENNEntity.fromEntity(entity: parent));
      }
    }

    // Return the newly converted GENNEntity
    return GENNEntity(
      dna: GENNDNA.fromDNA(dna: entity.dna),
      fitnessScore: entity.fitnessScore,
      parents: gennParents,
    );
  }

  @override
  GENNEntity copyWith({
    DNA<GENNPerceptron>? dna,
    double? fitnessScore,
    List<Entity<GENNPerceptron>>? parents,
  }) {
    return GENNEntity.fromEntity(
      entity: super.copyWith(
        dna: dna,
        fitnessScore: fitnessScore,
        parents: parents,
      ),
    );
  }

  @override
  List<GENNEntity>? get parents => _gennParents;

  @override
  GENNDNA get dna => _gennDna;

  @override
  List<Object?> get props => [
        ...super.props,
        _gennParents,
        _gennDna,
      ];

  /// Converts the input [json] into a [GENNEntity] object.
  factory GENNEntity.fromJson(Map<String, dynamic> json) =>
      _$GENNEntityFromJson(json);

  /// Converts the [GENNEntity] object to JSON.
  @override
  Map<String, dynamic> toJson() => _$GENNEntityToJson(this);
}
