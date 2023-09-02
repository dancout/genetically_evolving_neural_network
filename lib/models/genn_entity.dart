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
