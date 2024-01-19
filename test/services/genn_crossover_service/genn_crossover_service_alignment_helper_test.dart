import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  const firstLayer = 0;
  const secondLayer = 1;
  const thirdLayer = 2;
  const bias = 0.1;
  const threshold = 0.2;
  const weights = <double>[];
  const fitnessScore = 1.0;
  const crossedOverFitnessScore = 2.0;
  const maxLayerNum = 2;
  const minLayerNum = 0;
  const targetNumLayers = 1;
  const gennPerceptron = GENNPerceptron(
    layer: firstLayer,
    bias: bias,
    threshold: threshold,
    weights: weights,
  );
  const firstLayerGennGene = GENNGene(
    value: gennPerceptron,
  );
  final secondLayerGennGene = GENNGene(
    value: gennPerceptron.copyWith(layer: secondLayer),
  );
  final thirdLayerGennGene = GENNGene(
    value: gennPerceptron.copyWith(layer: thirdLayer),
  );

  final gennGenes = [
    firstLayerGennGene,
  ];
  final firstLayerGennEntity = GENNEntity(
    dna: GENNDNA(
      genes: gennGenes,
    ),
    fitnessScore: fitnessScore,
  );

  final secondLayerGennEntity = GENNEntity(
    dna: GENNDNA(
      genes: [
        firstLayerGennGene,
        secondLayerGennGene,
      ],
    ),
    fitnessScore: fitnessScore,
  );

  final secondLayerCrossodOverGennEntity = GENNEntity(
    dna: GENNDNA(
      genes: [
        firstLayerGennGene,
        secondLayerGennGene,
      ],
    ),
    fitnessScore: crossedOverFitnessScore,
  );

  final firstLayerCrossedOverGennEntity = GENNEntity(
    dna: GENNDNA(
      genes: gennGenes,
    ),
    fitnessScore: crossedOverFitnessScore,
  );

  final thirdLayerGennEntity = GENNEntity(
    dna: GENNDNA(
      genes: [
        firstLayerGennGene,
        secondLayerGennGene,
        thirdLayerGennGene,
      ],
    ),
    fitnessScore: fitnessScore,
  );
  final copiedParents = [
    firstLayerGennEntity,
    thirdLayerGennEntity,
  ];
  const numOutputs = 3;
  late PerceptronLayerMutationService mockPerceptronLayerMutationService;
  late GENNCrossoverServiceHelper mockGennCrossoverServiceHelper;
  late GENNCrossoverServiceAlignmentPerceptronHelper
      mockGennCrossoverServiceAlignmentPerceptronHelper;

  late GENNCrossoverServiceAlignmentHelper testObject;

  setUp(() async {
    mockPerceptronLayerMutationService = MockPerceptronLayerMutationService();
    mockGennCrossoverServiceHelper = MockGennCrossoverServiceHelper();
    mockGennCrossoverServiceAlignmentPerceptronHelper =
        MockGennCrossoverServiceAlignmentPerceptronHelper();

    testObject = GENNCrossoverServiceAlignmentHelper(
      numOutputs: numOutputs,
      perceptronLayerMutationService: mockPerceptronLayerMutationService,
      gennCrossoverServiceAlignmentPerceptronHelper:
          mockGennCrossoverServiceAlignmentPerceptronHelper,
    );

    when(() => mockGennCrossoverServiceAlignmentPerceptronHelper
        .gennCrossoverServiceHelper).thenReturn(mockGennCrossoverServiceHelper);
  });

  group('alignNumLayersForParents', () {
    test('returns proper copiedParents', () async {
      when(
        () => mockGennCrossoverServiceHelper.maxLayerNum(
          parents: copiedParents,
        ),
      ).thenReturn(maxLayerNum);
      when(
        () => mockGennCrossoverServiceHelper.minLayerNum(
          maxLayerNum: maxLayerNum,
          parents: copiedParents,
        ),
      ).thenReturn(minLayerNum);

      when(() => mockGennCrossoverServiceHelper.alignMinAndMaxValues(
          maxValue: maxLayerNum,
          minValue: minLayerNum)).thenReturn(targetNumLayers);

      when(() => mockGennCrossoverServiceAlignmentPerceptronHelper
              .alignPerceptronLayersWithinEntity(
                  gennEntity: firstLayerGennEntity,
                  targetNumLayers: targetNumLayers))
          .thenAnswer((_) async => secondLayerGennEntity);

      when(() => mockGennCrossoverServiceAlignmentPerceptronHelper
              .alignPerceptronLayersWithinEntity(
                  gennEntity: thirdLayerGennEntity,
                  targetNumLayers: targetNumLayers))
          .thenAnswer((_) async => secondLayerGennEntity);

      final actual =
          await testObject.alignNumLayersForParents(parents: copiedParents);

      final expected = [
        secondLayerGennEntity,
        secondLayerGennEntity,
      ];
      expect(
        actual,
        expected,
      );

      verify(() => mockGennCrossoverServiceHelper.maxLayerNum(
          parents: any(named: 'parents')));
      verify(() => mockGennCrossoverServiceHelper.minLayerNum(
            maxLayerNum: maxLayerNum,
            parents: any(named: 'parents'),
          ));
      verify(() => mockGennCrossoverServiceHelper.alignMinAndMaxValues(
          maxValue: maxLayerNum, minValue: minLayerNum));
      verify(
        () => mockGennCrossoverServiceAlignmentPerceptronHelper
            .alignPerceptronLayersWithinEntity(
          gennEntity: firstLayerGennEntity,
          targetNumLayers: targetNumLayers,
        ),
      );
      verify(
        () => mockGennCrossoverServiceAlignmentPerceptronHelper
            .alignPerceptronLayersWithinEntity(
          gennEntity: thirdLayerGennEntity,
          targetNumLayers: targetNumLayers,
        ),
      );
      verifyNoMoreInteractions(mockGennCrossoverServiceHelper);
    });

    test(
        'does not call alignPerceptronLayersWithinEntity when maxLayerNums match targetNumLayers',
        () async {
      final copiedParents = [
        secondLayerGennEntity,
        secondLayerGennEntity,
      ];
      when(
        () => mockGennCrossoverServiceHelper.maxLayerNum(
          parents: copiedParents,
        ),
      ).thenReturn(maxLayerNum);
      when(
        () => mockGennCrossoverServiceHelper.minLayerNum(
          maxLayerNum: maxLayerNum,
          parents: copiedParents,
        ),
      ).thenReturn(minLayerNum);

      when(() => mockGennCrossoverServiceHelper.alignMinAndMaxValues(
          maxValue: maxLayerNum,
          minValue: minLayerNum)).thenReturn(targetNumLayers);

      when(() => mockGennCrossoverServiceAlignmentPerceptronHelper
              .alignPerceptronLayersWithinEntity(
                  gennEntity: secondLayerGennEntity,
                  targetNumLayers: targetNumLayers))
          .thenAnswer((_) async => secondLayerGennEntity);

      final actual =
          await testObject.alignNumLayersForParents(parents: copiedParents);

      final expected = [
        secondLayerGennEntity,
        secondLayerGennEntity,
      ];
      expect(
        actual,
        expected,
      );

      verify(() => mockGennCrossoverServiceHelper.maxLayerNum(
          parents: any(named: 'parents')));
      verify(() => mockGennCrossoverServiceHelper.minLayerNum(
            maxLayerNum: maxLayerNum,
            parents: any(named: 'parents'),
          ));
      verify(() => mockGennCrossoverServiceHelper.alignMinAndMaxValues(
          maxValue: maxLayerNum, minValue: minLayerNum));
      verifyNever(
        () => mockGennCrossoverServiceAlignmentPerceptronHelper
            .alignPerceptronLayersWithinEntity(
          gennEntity: secondLayerGennEntity,
          targetNumLayers: targetNumLayers,
        ),
      );
    });
  });

  group('alignGenesWithinLayersForParents', () {
    test(
        'throws assertion error when parents do not have same number of layers',
        () async {
      expect(
        () => testObject.alignGenesWithinLayersForParents(parents: [
          firstLayerGennEntity,
          thirdLayerGennEntity,
        ]),
        throwsAssertionError,
      );
    });

    test('returns proper value when is last layer', () async {
      when(
        () => mockGennCrossoverServiceAlignmentPerceptronHelper
            .alignGenesWithinLayer(
          entity: firstLayerGennEntity,
          targetLayer: firstLayer,
          targetGeneNum: numOutputs,
        ),
      ).thenAnswer((_) async => firstLayerCrossedOverGennEntity);

      final actual =
          await testObject.alignGenesWithinLayersForParents(parents: [
        firstLayerGennEntity,
        firstLayerGennEntity,
      ]);

      expect(
        actual,
        [
          firstLayerCrossedOverGennEntity,
          firstLayerCrossedOverGennEntity,
        ],
      );
    });

    test('returns proper value when is not last layer', () async {
      when(
        () => mockGennCrossoverServiceAlignmentPerceptronHelper
            .alignGenesWithinLayer(
          entity: secondLayerGennEntity,
          targetLayer: firstLayer,
          targetGeneNum: 0,
        ),
      ).thenAnswer((_) async => secondLayerCrossodOverGennEntity);

      when(
        () => mockGennCrossoverServiceAlignmentPerceptronHelper
            .alignGenesWithinLayer(
          entity: secondLayerCrossodOverGennEntity,
          targetLayer: secondLayer,
          targetGeneNum: numOutputs,
        ),
      ).thenAnswer((_) async => secondLayerCrossodOverGennEntity);

      when(
        () => mockGennCrossoverServiceAlignmentPerceptronHelper
            .alignNumPerceptronsWithinLayer(
          perceptronLayers: [
            GENNPerceptronLayer(perceptrons: const [gennPerceptron]),
            GENNPerceptronLayer(perceptrons: const [gennPerceptron]),
          ],
        ),
      ).thenReturn(firstLayer);

      final actual =
          await testObject.alignGenesWithinLayersForParents(parents: [
        secondLayerGennEntity,
        secondLayerGennEntity,
      ]);

      expect(
        actual,
        [
          secondLayerCrossodOverGennEntity,
          secondLayerCrossodOverGennEntity,
        ],
      );
    });
  });
}
