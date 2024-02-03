import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  const layer = 0;
  const bias = 0.1;
  const numOutputs = 1;
  const threshold = 0.2;
  const weights = [0.1];
  const fitnessScore = 1.0;
  const updatedFitnessScore = 2.0;
  const gennPerceptron = GENNPerceptron(
    layer: layer,
    bias: bias,
    threshold: threshold,
    weights: weights,
  );

  late GENNFitnessService mockFitnessService;
  late NumberGenerator mockNumberGenerator;
  late DNAManipulationService mockDnaManipulationService;
  late PerceptronLayerAlignmentHelper mockPerceptronLayerAlignmentHelper;
  late EntityManipulationServiceAdditionHelper
      mockEntityManipulationServiceAdditionHelper;
  late EntityManipulationService testObject;

  setUp(() async {
    mockFitnessService = MockGENNFitnessService();
    mockNumberGenerator = MockNumberGenerator();
    mockDnaManipulationService = MockDNAManipulationService();
    mockPerceptronLayerAlignmentHelper = MockPerceptronLayerAlignmentHelper();
    mockEntityManipulationServiceAdditionHelper =
        MockEntityManipulationServiceAdditionHelper();

    testObject = EntityManipulationService(
      numOutputs: numOutputs,
      dnaManipulationService: mockDnaManipulationService,
      perceptronLayerAlignmentHelper: mockPerceptronLayerAlignmentHelper,
      fitnessService: mockFitnessService,
      numberGenerator: mockNumberGenerator,
      entitymanipulationServiceAdditionHelper:
          mockEntityManipulationServiceAdditionHelper,
    );
  });

  group('duplicatePerceptronLayerWithinEntity', () {
    test('properly duplicates targetLayer within entity', () async {
      final targetLayer = gennPerceptron.layer;

      final gennPerceptrons = [
        gennPerceptron,
        gennPerceptron,
        gennPerceptron,
      ];
      final genes = gennPerceptrons
          .map((perceptron) => GENNGene(value: perceptron))
          .toList();

      final gennPerceptronLayer = GENNPerceptronLayer(
        perceptrons: gennPerceptrons,
      );

      final duplicatedPerceptrons = [
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
      ];
      final duplicatedPerceptronLayer = GENNPerceptronLayer(
        perceptrons: duplicatedPerceptrons,
      );
      final duplicatedGenes = duplicatedPerceptrons
          .map((perceptron) => GENNGene(value: perceptron))
          .toList();

      final entity = GENNEntity(
        dna: GENNDNA(
          genes: genes,
        ),
        fitnessScore: fitnessScore,
      );

      final expected = GENNEntity(
        dna: GENNDNA(
          genes: [
            ...genes,
            ...duplicatedGenes,
          ],
        ),
        fitnessScore: fitnessScore,
      );

      when(
        () => mockEntityManipulationServiceAdditionHelper
            .duplicatePerceptronLayer(
          gennPerceptronLayer: gennPerceptronLayer,
        ),
      ).thenReturn(duplicatedPerceptronLayer);

      when(
        () => mockEntityManipulationServiceAdditionHelper
            .addPerceptronLayerToEntity(
          entity: entity,
          perceptronLayer: duplicatedPerceptronLayer,
        ),
      ).thenAnswer((_) async => expected);

      final actual = await testObject.duplicatePerceptronLayerWithinEntity(
        entity: entity,
        targetLayer: targetLayer,
      );

      expect(actual, expected);

      verify(
        () => mockEntityManipulationServiceAdditionHelper
            .duplicatePerceptronLayer(gennPerceptronLayer: gennPerceptronLayer),
      );
      verify(
        () => mockEntityManipulationServiceAdditionHelper
            .addPerceptronLayerToEntity(
                entity: entity, perceptronLayer: duplicatedPerceptronLayer),
      );
      verifyNoMoreInteractions(mockEntityManipulationServiceAdditionHelper);
      verifyZeroInteractions(mockFitnessService);
      verifyZeroInteractions(mockDnaManipulationService);
      verifyZeroInteractions(mockNumberGenerator);
      verifyZeroInteractions(mockPerceptronLayerAlignmentHelper);
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
          .thenAnswer((_) async => updatedFitnessScore);
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
        fitnessScore: updatedFitnessScore,
      );

      final actual = await testObject.removePerceptronLayerFromEntity(
        entity: entity,
        targetLayer: targetLayer,
      );

      expect(actual, expected);
    });

    test('calls to align genes within layer when targetLayer is last layer',
        () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);
      const targetLayer = 2;
      const randNegOneToPosOne = -0.5;
      final updatedDna = GENNDNA(
        genes: [
          const GENNGene(
            value: gennPerceptron,
          ),
          GENNGene(
            value: secondGennPerceptron,
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

      final expected = GENNEntity(
        dna: updatedDna,
        fitnessScore: updatedFitnessScore,
      );

      when(() => mockFitnessService.calculateScore(dna: updatedDna))
          .thenAnswer((_) async => updatedFitnessScore);
      when(() => mockNumberGenerator.randomNegOneToPosOne)
          .thenReturn(randNegOneToPosOne);
      when(
        () => mockPerceptronLayerAlignmentHelper.alignGenesWithinLayer(
          entity: entity.copyWith(dna: updatedDna),
          targetLayer: targetLayer - 1,
          targetGeneNum: numOutputs,
        ),
      ).thenAnswer((invocation) async => entity.copyWith(dna: updatedDna));

      final actual = await testObject.removePerceptronLayerFromEntity(
        entity: entity,
        targetLayer: targetLayer,
      );

      expect(actual, expected);
    });
  });

  group('addPerceptronToLayer', () {
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
      final originalDNA = GENNDNA(
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
      );
      final entity = GENNEntity(
        dna: originalDNA,
        fitnessScore: fitnessScore,
      );

      when(() => mockDnaManipulationService.addPerceptronToDNA(
          dna: originalDNA, targetLayer: targetLayer)).thenReturn(updatedDna);
      when(() => mockFitnessService.calculateScore(dna: updatedDna))
          .thenAnswer((_) async => updatedFitnessScore);

      final expected = GENNEntity(
        dna: updatedDna,
        fitnessScore: updatedFitnessScore,
      );

      final actual = await testObject.addPerceptronToLayer(
        entity: entity,
        targetLayer: targetLayer,
      );

      expect(actual, expected);
    });
  });

  group('removePerceptronFromLayer', () {
    test('properly removed Perceptron from target layer', () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);
      const targetLayer = 1;
      const updatedBias = 0.99;

      final originalDNA = GENNDNA(
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
      );
      final entity = GENNEntity(
        dna: originalDNA,
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

      when(() => mockDnaManipulationService.removePerceptronFromDNA(
            dna: originalDNA,
            targetLayer: targetLayer,
          )).thenReturn(updatedDna);
      when(() => mockFitnessService.calculateScore(dna: updatedDna))
          .thenAnswer((_) async => updatedFitnessScore);

      final expected = GENNEntity(
        dna: updatedDna,
        fitnessScore: updatedFitnessScore,
      );

      final actual = await testObject.removePerceptronFromLayer(
        entity: entity,
        targetLayer: targetLayer,
      );

      expect(actual, expected);
    });
  });
}
