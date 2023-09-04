import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

class GENNGene extends Gene<GENNPerceptron> {
  const GENNGene({
    required super.value,
    super.mutatedWaves,
  });

  factory GENNGene.fromGene({required Gene gene}) {
    return GENNGene(
      value: gene.value,
      mutatedWaves: gene.mutatedWaves,
    );
  }

  GENNGene copyWith({
    GENNPerceptron? value,
    List<int>? mutatedWaves,
  }) {
    return GENNGene(
      value: value ?? this.value,
      mutatedWaves: mutatedWaves ?? this.mutatedWaves,
    );
  }
}
