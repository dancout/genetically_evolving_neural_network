import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  const fitnessScore = 1.0;
  const updatedFitnessScore = 2.0;
  const layer = 0;
  const bias = 0.1;
  const threshold = 0.2;
  final weights = <double>[];

  final gennPerceptron = GENNPerceptron(
    layer: layer,
    bias: bias,
    threshold: threshold,
    weights: weights,
  );
  final gennEntity = GENNEntity(
    dna: GENNDNA(genes: [
      GENNGene(
        value: gennPerceptron,
      ),
    ]),
    fitnessScore: fitnessScore,
  );
  final updatedGennEntity = gennEntity.copyWith(
    fitnessScore: updatedFitnessScore,
  );

  late DNAManipulationService mockDNAManipulationService;
  late GENNFitnessService mockFitnessService;

  late PerceptronLayerAlignmentHelper testObject;

  setUp(() async {
    mockDNAManipulationService = MockDNAManipulationService();
    mockFitnessService = MockGENNFitnessService();

    testObject = PerceptronLayerAlignmentHelper(
      dnaManipulationService: mockDNAManipulationService,
      fitnessService: mockFitnessService,
    );
  });

  group('alignGenesWithinLayer', () {
    const targetLayer = 0;

    test(
        'returns proper GENNEntity when genesWithinTargetLayer is greater than targetGeneNum',
        () async {
      const targetGeneNum = 0;

      final originalDNA = GENNDNA(genes: [
        GENNGene(
          value: gennPerceptron,
        ),
        GENNGene(
          value: gennPerceptron,
        ),
      ]);
      final gennEntityTwoGenes = gennEntity.copyWith(dna: originalDNA);
      const updatedUpdatedFitnessScore = updatedFitnessScore + 1;

      final updatedUpdatedGennEntity = updatedGennEntity.copyWith(
        fitnessScore: updatedUpdatedFitnessScore,
      );

      when(
        () => mockDNAManipulationService.removePerceptronFromDNA(
          dna: gennEntityTwoGenes.dna,
          targetLayer: targetLayer,
        ),
      ).thenReturn(updatedGennEntity.dna);

      when(
        () => mockDNAManipulationService.removePerceptronFromDNA(
          dna: updatedGennEntity.dna,
          targetLayer: targetLayer,
        ),
      ).thenReturn(updatedUpdatedGennEntity.dna);

      when(() => mockFitnessService.calculateScore(
              dna: updatedUpdatedGennEntity.dna))
          .thenAnswer((_) async => updatedUpdatedFitnessScore);

      final actual = await testObject.alignGenesWithinLayer(
        entity: gennEntityTwoGenes,
        targetLayer: targetLayer,
        targetGeneNum: targetGeneNum,
      );

      expect(actual, updatedUpdatedGennEntity);

      verify(
        () => mockDNAManipulationService.removePerceptronFromDNA(
          dna: gennEntityTwoGenes.dna,
          targetLayer: targetLayer,
        ),
      );
      verify(
        () => mockDNAManipulationService.removePerceptronFromDNA(
          dna: updatedGennEntity.dna,
          targetLayer: targetLayer,
        ),
      );

      verify(
        () => mockFitnessService.calculateScore(
            dna: updatedUpdatedGennEntity.dna),
      );

      verifyNoMoreInteractions(mockDNAManipulationService);
      verifyNoMoreInteractions(mockFitnessService);
    });

    test(
        'returns proper GENNEntity when genesWithinTargetLayer is equal to targetGeneNum',
        () async {
      const targetGeneNum = 1;

      final actual = await testObject.alignGenesWithinLayer(
        entity: gennEntity,
        targetLayer: targetLayer,
        targetGeneNum: targetGeneNum,
      );

      expect(actual, gennEntity);

      verifyZeroInteractions(mockDNAManipulationService);
      verifyZeroInteractions(mockFitnessService);
    });

    test(
        'returns proper GENNEntity when genesWithinTargetLayer is less than targetGeneNum',
        () async {
      const targetGeneNum = 3;

      final gennEntityTwoGenes = gennEntity.copyWith(
          dna: GENNDNA(genes: [
        GENNGene(
          value: gennPerceptron,
        ),
        GENNGene(
          value: gennPerceptron,
        ),
      ]));

      when(
        () => mockDNAManipulationService.addPerceptronToDNA(
          dna: gennEntity.dna,
          targetLayer: targetLayer,
        ),
      ).thenReturn(gennEntityTwoGenes.dna);

      when(
        () => mockDNAManipulationService.addPerceptronToDNA(
          dna: gennEntityTwoGenes.dna,
          targetLayer: targetLayer,
        ),
      ).thenReturn(updatedGennEntity.dna);

      when(() => mockFitnessService.calculateScore(dna: updatedGennEntity.dna))
          .thenAnswer((_) async => updatedFitnessScore);

      final actual = await testObject.alignGenesWithinLayer(
        entity: gennEntity,
        targetLayer: targetLayer,
        targetGeneNum: targetGeneNum,
      );

      expect(actual, updatedGennEntity);

      verify(
        () => mockDNAManipulationService.addPerceptronToDNA(
          dna: gennEntity.dna,
          targetLayer: targetLayer,
        ),
      );
      verify(
        () => mockDNAManipulationService.addPerceptronToDNA(
          dna: gennEntityTwoGenes.dna,
          targetLayer: targetLayer,
        ),
      );
      verify(
        () => mockFitnessService.calculateScore(dna: updatedGennEntity.dna),
      );

      verifyNoMoreInteractions(mockDNAManipulationService);
    });
  });
}
