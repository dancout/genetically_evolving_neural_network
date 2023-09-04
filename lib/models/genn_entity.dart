import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_dna.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

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

  // TODO: This recursion feels super innefficient, but what can you do?
  factory GENNEntity.fromEntity({required Entity<GENNPerceptron> entity}) {
    final gennParents = <GENNEntity>[];

    final parents = entity.parents;
    if (parents != null) {
      for (var parent in parents) {
        gennParents.add(GENNEntity.fromEntity(entity: parent));
      }
    }

    return GENNEntity(
      gennDna: GENNDNA.fromDNA(dna: entity.dna),
      fitnessScore: entity.fitnessScore,
      gennParents: gennParents,
    );
  }

  GENNEntity copyWith({
    GENNDNA? gennDna,
    double? fitnessScore,
    List<GENNEntity>? gennParents,
  }) {
    return GENNEntity(
      gennDna: gennDna ?? this.gennDna,
      fitnessScore: fitnessScore ?? this.fitnessScore,
      gennParents: gennParents ?? this.gennParents,
    );
  }
}
