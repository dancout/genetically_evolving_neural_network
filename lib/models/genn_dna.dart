part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [GeneticEvolution.DNA].
@JsonSerializable()
class GENNDNA extends DNA<GENNPerceptron> {
  /// An extension of [GeneticEvolution.DNA].
  GENNDNA({
    required List<GENNGene> genes,
  })  : _gennGenes = genes,
        super(
            genes: genes
              // Sort the genes by Perceptron layer for consistency.
              // NOTE:  This is necessary, otherwise perceptrons may be crossed
              //        over among different layers, which is unintentional.
              ..sort(
                (a, b) => (a.value.layer > b.value.layer) ? 1 : -1,
              ));

  final List<GENNGene> _gennGenes;

  /// Returns a [GENNDNA] object created from the input [DNA].
  factory GENNDNA.fromDNA({required DNA<GENNPerceptron> dna}) {
    final gennGenes = <GENNGene>[];

    for (var gene in dna.genes) {
      gennGenes.add(GENNGene.fromGene(gene: gene));
    }

    return GENNDNA(genes: gennGenes);
  }

  @override
  List<GENNGene> get genes => _gennGenes;

  @override
  List<Object?> get props => [
        ...super.props,
        _gennGenes,
      ];

  /// Converts the input [json] into a [GENNDNA] object.
  factory GENNDNA.fromJson(Map<String, dynamic> json) =>
      _$GENNDNAFromJson(json);

  /// Converts the [GENNDNA] object to JSON.
  @override
  Map<String, dynamic> toJson() => _$GENNDNAToJson(this);
}
