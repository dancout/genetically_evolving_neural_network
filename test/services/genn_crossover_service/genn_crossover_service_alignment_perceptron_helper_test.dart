import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

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

  late PerceptronLayerMutationService mockPerceptronLayerMutationService;
  late GENNCrossoverServiceHelper mockGennCrossoverServiceHelper;
  late GENNCrossoverServiceAlignmentPerceptronHelper testObject;

  setUp(() async {
    mockPerceptronLayerMutationService = MockPerceptronLayerMutationService();
    mockGennCrossoverServiceHelper = MockGennCrossoverServiceHelper();
    testObject = GENNCrossoverServiceAlignmentPerceptronHelper(
      perceptronLayerMutationService: mockPerceptronLayerMutationService,
      gennCrossoverServiceHelper: mockGennCrossoverServiceHelper,
    );
  });

  group('alignPerceptronLayersWithinEntity', () {
    test(
        'returns proper GENNEntity when maxLayerNum is less than targetNumLayers',
        () async {
      const targetNumLayers = 1;

      final gennPerceptronLayer =
          GENNPerceptronLayer(perceptrons: [gennPerceptron]);

      when(() => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
              gennPerceptronLayer: gennPerceptronLayer))
          .thenReturn(gennPerceptronLayer);

      when(() => mockPerceptronLayerMutationService.addPerceptronLayerToEntity(
          entity: gennEntity,
          perceptronLayer: gennPerceptronLayer)).thenReturn(updatedGennEntity);

      final actual = await testObject.alignPerceptronLayersWithinEntity(
        gennEntity: gennEntity,
        targetNumLayers: targetNumLayers,
      );

      expect(actual, updatedGennEntity);

      verify(
        () => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: gennPerceptronLayer,
        ),
      );
      verify(
        () => mockPerceptronLayerMutationService.addPerceptronLayerToEntity(
          entity: gennEntity,
          perceptronLayer: gennPerceptronLayer,
        ),
      );

      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'returns proper GENNEntity when maxLayerNum is equal to targetNumLayers',
        () async {
      const targetNumLayers = 0;

      final actual = await testObject.alignPerceptronLayersWithinEntity(
        gennEntity: gennEntity,
        targetNumLayers: targetNumLayers,
      );

      expect(actual, gennEntity);

      verifyZeroInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'returns proper GENNEntity when maxLayerNum is greater than targetNumLayers',
        () async {
      const targetNumLayers = 0;

      const secondLayer = targetNumLayers + 1;
      const thirdLayer = secondLayer + 1;
      final secondLayerGennPerceptron = gennPerceptron.copyWith(
        layer: secondLayer,
      );

      final thirdLayerGennPerceptron = gennPerceptron.copyWith(
        layer: thirdLayer,
      );
      final secondLayerGennEntity = gennEntity.copyWith(
        dna: GENNDNA(
          genes: [
            GENNGene(
              value: secondLayerGennPerceptron,
            ),
          ],
        ),
      );
      final thirdLayerGennEntity = gennEntity.copyWith(
        dna: GENNDNA(
          genes: [
            GENNGene(
              value: thirdLayerGennPerceptron,
            ),
          ],
        ),
      );

      when(
        () =>
            mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
          entity: thirdLayerGennEntity,
          targetLayer: thirdLayer,
        ),
      ).thenAnswer(
        (_) async => secondLayerGennEntity,
      );
      when(
        () =>
            mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
          entity: secondLayerGennEntity,
          targetLayer: secondLayer,
        ),
      ).thenAnswer(
        (_) async => gennEntity,
      );

      final actual = await testObject.alignPerceptronLayersWithinEntity(
        gennEntity: thirdLayerGennEntity,
        targetNumLayers: targetNumLayers,
      );

      expect(actual, gennEntity);

      verify(
        () =>
            mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
          entity: secondLayerGennEntity,
          targetLayer: secondLayer,
        ),
      );

      verify(
        () =>
            mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
          entity: thirdLayerGennEntity,
          targetLayer: thirdLayer,
        ),
      );

      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });
  });

  group('alignGenesWithinLayer', () {
    const targetLayer = 0;

    test(
        'returns proper GENNEntity when genesWithinTargetLayer is greater than targetGeneNum',
        () async {
      const targetGeneNum = 0;

      final gennEntityTwoGenes = gennEntity.copyWith(
          dna: GENNDNA(genes: [
        GENNGene(
          value: gennPerceptron,
        ),
        GENNGene(
          value: gennPerceptron,
        ),
      ]));
      const updatedUpdatedFitnessScore = updatedFitnessScore + 1;

      final updatedUpdatedGennEntity = updatedGennEntity.copyWith(
        fitnessScore: updatedUpdatedFitnessScore,
      );

      when(
        () => mockPerceptronLayerMutationService.removePerceptronFromLayer(
          entity: gennEntityTwoGenes,
          targetLayer: targetLayer,
        ),
      ).thenAnswer(
        (_) async => updatedGennEntity,
      );

      when(
        () => mockPerceptronLayerMutationService.removePerceptronFromLayer(
          entity: updatedGennEntity,
          targetLayer: targetLayer,
        ),
      ).thenAnswer(
        (_) async => updatedUpdatedGennEntity,
      );

      final actual = await testObject.alignGenesWithinLayer(
        entity: gennEntityTwoGenes,
        targetLayer: targetLayer,
        targetGeneNum: targetGeneNum,
      );

      expect(actual, updatedUpdatedGennEntity);

      verify(
        () => mockPerceptronLayerMutationService.removePerceptronFromLayer(
          entity: gennEntityTwoGenes,
          targetLayer: targetLayer,
        ),
      );
      verify(
        () => mockPerceptronLayerMutationService.removePerceptronFromLayer(
          entity: updatedGennEntity,
          targetLayer: targetLayer,
        ),
      );

      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
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

      verifyZeroInteractions(mockPerceptronLayerMutationService);
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
        () => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: gennEntity,
          targetLayer: targetLayer,
        ),
      ).thenAnswer(
        (_) async => gennEntityTwoGenes,
      );

      when(
        () => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: gennEntityTwoGenes,
          targetLayer: targetLayer,
        ),
      ).thenAnswer(
        (_) async => updatedGennEntity,
      );

      final actual = await testObject.alignGenesWithinLayer(
        entity: gennEntity,
        targetLayer: targetLayer,
        targetGeneNum: targetGeneNum,
      );

      expect(actual, updatedGennEntity);

      verify(
        () => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: gennEntity,
          targetLayer: targetLayer,
        ),
      );
      verify(
        () => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: gennEntityTwoGenes,
          targetLayer: targetLayer,
        ),
      );

      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });
  });

  group('alignNumPerceptronsWithinLayer', () {
    test(
        'returns proper value and calls gennCrossoverServiceHelper.alignMinAndMaxValues',
        () async {
      const maxNumber = 3;
      const minNumber = 1;
      const middleNumber = 2;

      when(() => mockGennCrossoverServiceHelper.alignMinAndMaxValues(
          maxValue: maxNumber, minValue: minNumber)).thenReturn(middleNumber);

      final perceptronLayers = [
        GENNPerceptronLayer(
          perceptrons: [
            gennPerceptron,
          ],
        ),
        GENNPerceptronLayer(
          perceptrons: [
            gennPerceptron,
            gennPerceptron,
            gennPerceptron,
          ],
        )
      ];

      final actual = testObject.alignNumPerceptronsWithinLayer(
        perceptronLayers: perceptronLayers,
      );

      expect(actual, middleNumber);

      verify(
        () => mockGennCrossoverServiceHelper.alignMinAndMaxValues(
          maxValue: maxNumber,
          minValue: minNumber,
        ),
      );

      verifyNoMoreInteractions(mockGennCrossoverServiceHelper);
    });
  });
}
