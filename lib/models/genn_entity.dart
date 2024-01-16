part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [GeneticEvolution.Entity]
class GENNEntity extends Entity<GENNPerceptron> {
  const GENNEntity({
    required this.gennDna,
    required super.fitnessScore,
    this.gennParents,
  }) : super(
          dna: gennDna,
          parents: gennParents,
        );

  final List<GENNEntity>? gennParents;
  final GENNDNA gennDna;

  /// The highest Layer value present within the [gennDna]'s [gennGene] objects.
  int get maxLayerNum => gennDna.gennGenes.fold(
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
      gennDna: GENNDNA.fromDNA(dna: entity.dna),
      fitnessScore: entity.fitnessScore,
      gennParents: gennParents,
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
  List<Object?> get props => [
        ...super.props,
        gennParents,
        gennDna,
      ];
}
