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
    gennDna: GENNDNA(gennGenes: [
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
          GENNPerceptronLayer(gennPerceptrons: [gennPerceptron]);

      when(() => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
              gennPerceptronLayer: gennPerceptronLayer))
          .thenReturn(gennPerceptronLayer);

      when(() => mockPerceptronLayerMutationService.addPerceptronLayer(
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
        () => mockPerceptronLayerMutationService.addPerceptronLayer(
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
      final secondLayerGennPerceptron = gennPerceptron.copyWith(
        layer: secondLayer,
      );
      final secondLayerGennEntity = gennEntity.copyWith(
        gennDna: GENNDNA(
          gennGenes: [
            GENNGene(
              value: secondLayerGennPerceptron,
            ),
          ],
        ),
      );
      final updatedSecondLayerGennEntity = secondLayerGennEntity.copyWith(
        fitnessScore: updatedFitnessScore,
      );
      when(
        () =>
            mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
          entity: secondLayerGennEntity,
          targetLayer: secondLayer,
        ),
      ).thenAnswer(
        (_) async => updatedSecondLayerGennEntity,
      );

      final actual = await testObject.alignPerceptronLayersWithinEntity(
        gennEntity: secondLayerGennEntity,
        targetNumLayers: targetNumLayers,
      );

      expect(actual, updatedSecondLayerGennEntity);

      // TODO: Could write better test to make sure this was called X amount of
      /// times for when the diff value is greater than 1.
      verify(
        () =>
            mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
          entity: secondLayerGennEntity,
          targetLayer: secondLayer,
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
          gennDna: GENNDNA(gennGenes: [
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
          gennDna: GENNDNA(gennGenes: [
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
          gennPerceptrons: [
            gennPerceptron,
          ],
        ),
        GENNPerceptronLayer(
          gennPerceptrons: [
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
