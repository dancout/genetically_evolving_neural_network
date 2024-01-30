import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  const layer = 0;
  const bias = 0.1;
  const threshold = 0.2;
  const weights = [0.1];
  const fitnessScore = 1.0;
  const gennPerceptron = GENNPerceptron(
    layer: layer,
    bias: bias,
    threshold: threshold,
    weights: weights,
  );

  late GennGeneServiceHelper mockGeneServiceHelper;
  late GENNFitnessService mockFitnessService;
  late NumberGenerator mockNumberGenerator;
  late PerceptronLayerMutationService testObject;

  setUp(() async {
    mockGeneServiceHelper = MockGennGeneServiceHelper();
    mockFitnessService = MockGENNFitnessService();
    mockNumberGenerator = MockNumberGenerator();

    testObject = PerceptronLayerMutationService(
      gennGeneServiceHelper: mockGeneServiceHelper,
      fitnessService: mockFitnessService,
      numberGenerator: mockNumberGenerator,
    );
  });

  group('duplicatePerceptronLayer', () {
    test(
        'returns PerceptronLayer with duplicated perceptrons and proper weights',
        () async {
      final gennPerceptrons = [
        gennPerceptron,
        gennPerceptron,
        gennPerceptron,
      ];
      final gennPerceptronLayer = GENNPerceptronLayer(
        perceptrons: gennPerceptrons,
      );

      final actual = testObject.duplicatePerceptronLayer(
        gennPerceptronLayer: gennPerceptronLayer,
      );

      expect(
        actual,
        GENNPerceptronLayer(
          perceptrons: [
            gennPerceptron.copyWith(
              weights: [1.0, 0.0, 0.0],
              layer: 1,
            ),
            gennPerceptron.copyWith(
              weights: [0.0, 1.0, 0.0],
              layer: 1,
            ),
            gennPerceptron.copyWith(
              weights: [0.0, 0.0, 1.0],
              layer: 1,
            ),
          ],
        ),
      );
    });
  });

  group('addPerceptronLayer', () {
    test('properly inserts PerceptronLayer into Entity', () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);

      final perceptronLayer = GENNPerceptronLayer(
        perceptrons: [secondGennPerceptron],
      );

      final entity = GENNEntity(
        dna: GENNDNA(
          genes: [
            const GENNGene(
              value: gennPerceptron,
            ),
            GENNGene(
              value: secondGennPerceptron,
            ),
            GENNGene(
              value: thirdGennPerceptron,
            ),
          ],
        ),
        fitnessScore: fitnessScore,
      );

      final expected = GENNEntity(
        dna: GENNDNA(
          genes: [
            const GENNGene(
              value: gennPerceptron,
            ),
            GENNGene(
              value: secondGennPerceptron,
            ),
            GENNGene(
              value: secondGennPerceptron.copyWith(
                layer: secondGennPerceptron.layer + 1,
              ),
            ),
            GENNGene(
              value: thirdGennPerceptron.copyWith(
                layer: thirdGennPerceptron.layer + 1,
              ),
            ),
          ],
        ),
        fitnessScore: fitnessScore,
      );

      final actual = testObject.addPerceptronLayerToEntity(
        entity: entity,
        perceptronLayer: perceptronLayer,
      );

      expect(actual, expected);
    });
  });

  group('removePerceptronLayerFromEntity', () {
    test('properly removes targetLayer from entity', () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);
      const targetLayer = 1;
      const randNegOneToPosOne = -0.5;
      final updatedDna = GENNDNA(
        genes: [
          const GENNGene(
            value: gennPerceptron,
          ),
          GENNGene(
            value: thirdGennPerceptron.copyWith(
              layer: thirdGennPerceptron.layer - 1,
              weights: [randNegOneToPosOne],
            ),
          ),
        ],
      );
      when(() => mockFitnessService.calculateScore(dna: updatedDna))
          .thenAnswer((_) async => fitnessScore);
      when(() => mockNumberGenerator.randomNegOneToPosOne)
          .thenReturn(randNegOneToPosOne);

      final entity = GENNEntity(
        dna: GENNDNA(
          genes: [
            const GENNGene(
              value: gennPerceptron,
            ),
            GENNGene(
              value: secondGennPerceptron,
            ),
            GENNGene(
              value: thirdGennPerceptron,
            ),
          ],
        ),
        fitnessScore: fitnessScore,
      );

      final expected = GENNEntity(
        dna: updatedDna,
        fitnessScore: fitnessScore,
      );

      final actual = await testObject.removePerceptronLayerFromEntity(
        entity: entity,
        targetLayer: targetLayer,
      );

      expect(actual, expected);
    });
  });

  group('addPerceptronToLayer', () {
    test('throws assertion error when targetLayer is last perceptron layer',
        () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);
      const targetLayer = 2;

      final entity = GENNEntity(
        dna: GENNDNA(
          genes: [
            const GENNGene(
              value: gennPerceptron,
            ),
            GENNGene(
              value: secondGennPerceptron,
            ),
            GENNGene(
              value: thirdGennPerceptron,
            ),
          ],
        ),
        fitnessScore: fitnessScore,
      );

      expect(
        () => testObject.addPerceptronToLayer(
          entity: entity,
          targetLayer: targetLayer,
        ),
        throwsAssertionError,
      );
    });

    test('properly adds Perceptron to PerceptronLayer', () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);
      const targetLayer = 1;
      const randNegOneToPosOne = -0.5;

      const randomWeights = [-0.99];
      const randomPerceptron = GENNPerceptron(
        layer: targetLayer,
        bias: bias,
        threshold: threshold,
        weights: randomWeights,
      );
      final updatedDna = GENNDNA(
        genes: [
          const GENNGene(
            value: gennPerceptron,
          ),
          GENNGene(
            value: secondGennPerceptron,
          ),
          const GENNGene(
            value: randomPerceptron,
          ),
          GENNGene(
            value: thirdGennPerceptron.copyWith(
              weights: [
                ...thirdGennPerceptron.weights,
                randNegOneToPosOne,
              ],
            ),
          ),
        ],
      );
      final entity = GENNEntity(
        dna: GENNDNA(
          genes: [
            const GENNGene(
              value: gennPerceptron,
            ),
            GENNGene(
              value: secondGennPerceptron,
            ),
            GENNGene(
              value: thirdGennPerceptron,
            ),
          ],
        ),
        fitnessScore: fitnessScore,
      );

      when(
        () => mockGeneServiceHelper.randomPerceptron(
          numWeights: 1,
          layer: targetLayer,
        ),
      ).thenReturn(
        randomPerceptron,
      );
      when(() => mockNumberGenerator.randomNegOneToPosOne)
          .thenReturn(randNegOneToPosOne);
      when(() => mockFitnessService.calculateScore(dna: updatedDna))
          .thenAnswer((_) async => fitnessScore);

      final expected = GENNEntity(
        dna: updatedDna,
        fitnessScore: fitnessScore,
      );

      final actual = await testObject.addPerceptronToLayer(
        entity: entity,
        targetLayer: targetLayer,
      );

      expect(actual, expected);
    });
  });

  group('removePerceptronFromLayer', () {
    test(
        'throws assertion error if you try to remove the only perceptron in a given layer',
        () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);
      const targetLayer = 1;

      final entity = GENNEntity(
        dna: GENNDNA(
          genes: [
            const GENNGene(
              value: gennPerceptron,
            ),
            GENNGene(
              value: secondGennPerceptron,
            ),
            GENNGene(
              value: thirdGennPerceptron,
            ),
          ],
        ),
        fitnessScore: fitnessScore,
      );

      expect(
        () => testObject.removePerceptronFromLayer(
            entity: entity, targetLayer: targetLayer),
        throwsAssertionError,
      );
    });

    test('properly removed Perceptron from target layer', () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);
      const targetLayer = 1;
      const updatedBias = 0.99;

      final entity = GENNEntity(
        dna: GENNDNA(
          genes: [
            const GENNGene(
              value: gennPerceptron,
            ),
            GENNGene(
              value: secondGennPerceptron,
            ),
            GENNGene(
              value: secondGennPerceptron.copyWith(
                bias: updatedBias,
              ),
            ),
            GENNGene(
              value: secondGennPerceptron,
            ),
            GENNGene(
              value: thirdGennPerceptron,
            ),
          ],
        ),
        fitnessScore: fitnessScore,
      );

      final updatedDna = GENNDNA(
        genes: [
          const GENNGene(
            value: gennPerceptron,
          ),
          GENNGene(
            value: secondGennPerceptron.copyWith(
              bias: updatedBias,
            ),
          ),
          GENNGene(
            value: secondGennPerceptron,
          ),
          GENNGene(
            value: thirdGennPerceptron.copyWith(
              weights: [],
            ),
          ),
        ],
      );

      when(() => mockFitnessService.calculateScore(dna: updatedDna))
          .thenAnswer((_) async => fitnessScore);
      when(() => mockNumberGenerator.nextInt(3)).thenReturn(0);

      final expected = GENNEntity(
        dna: updatedDna,
        fitnessScore: fitnessScore,
      );

      final actual = await testObject.removePerceptronFromLayer(
        entity: entity,
        targetLayer: targetLayer,
      );

      expect(actual, expected);
    });
  });
}
