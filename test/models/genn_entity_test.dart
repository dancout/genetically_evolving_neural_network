import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

void main() {
  const gennPerceptron = GENNPerceptron(
    layer: 0,
    bias: 0,
    threshold: 0,
    weights: [0],
  );
  test('maxLayerNum returns the highest layer value present', () async {
    var gennGenes = [
      const GENNGene(
        value: gennPerceptron,
      ),
      GENNGene(
        value: gennPerceptron.copyWith(layer: 5),
      ),
      GENNGene(
        value: gennPerceptron.copyWith(layer: 4),
      ),
      GENNGene(
        value: gennPerceptron.copyWith(layer: 3),
      ),
      GENNGene(
        value: gennPerceptron.copyWith(layer: 2),
      ),
      GENNGene(
        value: gennPerceptron.copyWith(layer: 1),
      ),
    ];
    final testObject = GENNEntity(
      dna: GENNDNA(
        genes: gennGenes,
      ),
      fitnessScore: 0.0,
    );

    expect(testObject.maxLayerNum, 5);
  });

  group('fromEntity', () {
    test('creates a GENNEntity from the given Entity', () async {
      const fitnessScore = 1.0;
      const parentFitnessScore = 1.5;
      const dna = DNA<GENNPerceptron>(
        genes: [
          Gene<GENNPerceptron>(
            value: gennPerceptron,
          ),
        ],
      );
      final emptyList = <GENNGene>[];
      final gennParents = [
        GENNEntity(
          dna: GENNDNA(genes: emptyList),
          fitnessScore: parentFitnessScore,
        ),
      ];
      final entity = Entity<GENNPerceptron>(
        dna: dna,
        fitnessScore: fitnessScore,
        parents: gennParents,
      );

      final asdf = [const GENNGene(value: gennPerceptron)];
      expect(
        GENNEntity.fromEntity(entity: entity),
        GENNEntity(
          dna: GENNDNA(genes: asdf),
          fitnessScore: fitnessScore,
          parents: gennParents,
        ),
      );
    });
  });

  group('copyWith', () {
    test('copies the proper values', () async {
      const fitnessScore = 1.0;
      const parentFitnessScore = 1.5;
      final emptyList = <GENNGene>[];
      final gennParents = [
        GENNEntity(
          dna: GENNDNA(genes: emptyList),
          fitnessScore: parentFitnessScore,
        ),
      ];
      var gennGenes = [
        const GENNGene(
          value: gennPerceptron,
        ),
        GENNGene(
          value: gennPerceptron.copyWith(layer: 5),
        ),
        GENNGene(
          value: gennPerceptron.copyWith(layer: 4),
        ),
        GENNGene(
          value: gennPerceptron.copyWith(layer: 3),
        ),
        GENNGene(
          value: gennPerceptron.copyWith(layer: 2),
        ),
        GENNGene(
          value: gennPerceptron.copyWith(layer: 1),
        ),
      ];

      final originalGennEntity = GENNEntity(
        dna: GENNDNA(
          genes: gennGenes,
        ),
        fitnessScore: fitnessScore,
      );

      const updatedFitnessScore = 2.0;
      var updatedGennGenes = [
        const GENNGene(
          value: gennPerceptron,
        ),
      ];
      final updatedGennDNA = GENNDNA(genes: updatedGennGenes);
      final copiedWithFitnessScore =
          originalGennEntity.copyWith(fitnessScore: updatedFitnessScore);
      expect(
        copiedWithFitnessScore.fitnessScore,
        updatedFitnessScore,
      );
      expect(
        copiedWithFitnessScore.dna,
        GENNDNA(genes: gennGenes),
      );
      expect(
        copiedWithFitnessScore.parents,
        isNull,
      );

      final copiedWithGennDna =
          originalGennEntity.copyWith(dna: updatedGennDNA);
      expect(
        copiedWithGennDna.dna,
        updatedGennDNA,
      );
      expect(
        copiedWithGennDna.fitnessScore,
        fitnessScore,
      );
      expect(
        copiedWithGennDna.parents,
        isNull,
      );

      final copiedWithParents = originalGennEntity.copyWith(
        parents: gennParents,
      );
      expect(
        copiedWithParents.dna,
        GENNDNA(genes: gennGenes),
      );
      expect(
        copiedWithParents.fitnessScore,
        fitnessScore,
      );
      expect(
        copiedWithParents.parents,
        gennParents,
      );
    });
  });
}
