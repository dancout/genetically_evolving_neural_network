import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_dna.dart';
import 'package:genetically_evolving_neural_network/models/genn_gene.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';

void main() {
  const gennPerceptron = GENNPerceptron(
    layer: 0,
    bias: 0.1,
    threshold: 0.1,
    weights: [0.1],
  );
  const gennGeneLayer0 = GENNGene(
    value: gennPerceptron,
  );

  final gennGeneLayer1 = GENNGene(
    value: gennPerceptron.copyWith(layer: 1),
  );

  final gennGeneLayer2 = GENNGene(
    value: gennPerceptron.copyWith(layer: 2),
  );
  final expectedGenes = [
    gennGeneLayer0,
    gennGeneLayer1,
    gennGeneLayer2,
  ];

  group('constructor', () {
    test('sorts genes by layer value', () async {
      final actual = GENNDNA(
        gennGenes: [
          gennGeneLayer2,
          gennGeneLayer0,
          gennGeneLayer1,
        ],
      ).gennGenes;

      expect(actual, expectedGenes);
    });
  });

  group('fromDNA', () {
    test('converts the input DNA list of genes into GENNGenes', () async {
      final actual = GENNDNA
          .fromDNA(
            dna: DNA(
              genes: [
                gennGeneLayer2,
                gennGeneLayer0,
                gennGeneLayer1,
              ],
            ),
          )
          .gennGenes;

      expect(actual, expectedGenes);
      expect(actual.runtimeType, List<GENNGene>);
    });
  });
}
