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
  const updatedFitnessScore = 2.0;
  const gennPerceptron = GENNPerceptron(
    layer: layer,
    bias: bias,
    threshold: threshold,
    weights: weights,
  );

  late GENNFitnessService mockFitnessService;
  late EntityManipulationServiceAdditionHelper testObject;

  setUp(() async {
    mockFitnessService = MockGENNFitnessService();

    testObject = EntityManipulationServiceAdditionHelper(
      fitnessService: mockFitnessService,
    );
  });

  group('addPerceptronLayerToEntity', () {
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

      final updatedDNA = GENNDNA(
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
      );
      final expected = GENNEntity(
        dna: updatedDNA,
        fitnessScore: updatedFitnessScore,
      );

      when(() => mockFitnessService.calculateScore(dna: updatedDNA))
          .thenAnswer((_) async => updatedFitnessScore);

      final actual = await testObject.addPerceptronLayerToEntity(
        entity: entity,
        perceptronLayer: perceptronLayer,
      );

      expect(actual, expected);
    });
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

      final actual = testObject.duplicatePerceptronLayer(
        gennPerceptronLayer: gennPerceptronLayer,
      );

      expect(
        actual,
        duplicatedPerceptronLayer,
      );
    });
  });
}
