part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

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
