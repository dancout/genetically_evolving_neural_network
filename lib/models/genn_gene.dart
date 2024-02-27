part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [GeneticEvolution.Gene].
@JsonSerializable()
class GENNGene extends Gene<GENNPerceptron> {
  const GENNGene({
    required super.value,
    super.mutatedWaves,
  });

  /// Returns a [GENNGene] object created from the input [Gene].
  factory GENNGene.fromGene({required Gene<GENNPerceptron> gene}) {
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

  /// Converts the input [json] into a [GENNGene] object.
  factory GENNGene.fromJson(Map<String, dynamic> json) =>
      _$GENNGeneFromJson(json);

  /// Converts the [GENNGene] object to JSON.
  @override
  Map<String, dynamic> toJson() => _$GENNGeneToJson(this);
}
