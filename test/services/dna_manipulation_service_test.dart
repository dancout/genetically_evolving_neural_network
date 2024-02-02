import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  const layer = 0;
  const bias = 0.1;
  const threshold = 0.2;
  final weights = [0.1];
  final gennPerceptron = GENNPerceptron(
    layer: layer,
    bias: bias,
    threshold: threshold,
    weights: weights,
  );

  late GennGeneServiceHelper mockGennGeneServiceHelper;
  late NumberGenerator mockNumberGenerator;
  late DNAManipulationService testObject;

  setUp(() async {
    mockGennGeneServiceHelper = MockGennGeneServiceHelper();
    mockNumberGenerator = MockNumberGenerator();

    testObject = DNAManipulationService(
      gennGeneServiceHelper: mockGennGeneServiceHelper,
      numberGenerator: mockNumberGenerator,
    );
  });

  group('addPerceptronToDNA', () {
    test('properly adds Perceptron within DNA', () async {
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
          GENNGene(
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
          GENNGene(
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

      when(
        () => mockGennGeneServiceHelper.randomPerceptron(
          numWeights: 1,
          layer: targetLayer,
        ),
      ).thenReturn(
        randomPerceptron,
      );
      when(() => mockNumberGenerator.randomNegOneToPosOne)
          .thenReturn(randNegOneToPosOne);

      final actual = testObject.addPerceptronToDNA(
        dna: originalDNA,
        targetLayer: targetLayer,
      );

      expect(actual, updatedDna);
      verify(
        () => mockGennGeneServiceHelper.randomPerceptron(
          numWeights: 1,
          layer: targetLayer,
        ),
      );
      verify(() => mockNumberGenerator.randomNegOneToPosOne);
    });
  });

  group('removePerceptronFromDNA', () {
    test(
        'throws assertion error if you try to remove the only perceptron in a given layer',
        () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);
      const targetLayer = 1;

      final originalDNA = GENNDNA(
        genes: [
          GENNGene(
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

      expect(
        () => testObject.removePerceptronFromDNA(
          dna: originalDNA,
          targetLayer: targetLayer,
        ),
        throwsAssertionError,
      );
    });

    test('properly removes Perceptron from target layer within DNA', () async {
      final secondGennPerceptron = gennPerceptron.copyWith(layer: layer + 1);
      final thirdGennPerceptron = gennPerceptron.copyWith(layer: layer + 2);
      const targetLayer = 1;
      const updatedBias = 0.99;

      var originalDNA = GENNDNA(
        genes: [
          GENNGene(
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

      final updatedDna = GENNDNA(
        genes: [
          GENNGene(
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

      when(() => mockNumberGenerator.nextInt(3)).thenReturn(0);

      final actual = await testObject.removePerceptronFromDNA(
        dna: originalDNA,
        targetLayer: targetLayer,
      );

      expect(actual, updatedDna);

      verify(() => mockNumberGenerator.nextInt(3));
    });
  });
}
