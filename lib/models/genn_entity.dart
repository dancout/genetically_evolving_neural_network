import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

class GENNEntity extends Entity<GENNPerceptron> {
  const GENNEntity({
    required super.dna,
    required super.fitnessScore,
    this.gennParents,
  }) : super(parents: gennParents);

  final List<GENNEntity>? gennParents;

  GENNEntity copyWith({
    DNA<GENNPerceptron>? dna,
    double? fitnessScore,
    List<GENNEntity>? gennParents,
  }) {
    return GENNEntity(
      dna: dna ?? this.dna,
      fitnessScore: fitnessScore ?? this.fitnessScore,
      gennParents: gennParents ?? this.gennParents,
    );
  }
}
