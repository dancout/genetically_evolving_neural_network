import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  const layer = 1;
  const bias = 0.1;
  const threshold = -0.3;
  final weights = [0.1, 0.2, 0.3];
  final perceptron = GENNPerceptron(
    layer: layer,
    bias: bias,
    threshold: threshold,
    weights: weights,
  );

  late NumberGenerator mockNumberGenerator;
  late GennGeneServiceMutationHelper testObject;

  setUp(() async {
    mockNumberGenerator = MockNumberGenerator();

    testObject = GennGeneServiceMutationHelper(
      numberGenerator: mockNumberGenerator,
    );
  });

  group('mutateBasedOnSelectedOption', () {
    test('selectedOption of 0 will update bias', () async {
      const randomNegOneToPosOne = -0.2;
      const selectedOption = 0;

      when(() => mockNumberGenerator.randomNegOneToPosOne)
          .thenReturn(randomNegOneToPosOne);

      final actual =
          testObject.mutateBasedOnSelectedOption(selectedOption, perceptron);

      expect(actual, perceptron.copyWith(bias: randomNegOneToPosOne));

      verifyNever(() => mockNumberGenerator.nextDouble);
      verify(() => mockNumberGenerator.randomNegOneToPosOne);
      verifyNoMoreInteractions(mockNumberGenerator);
    });

    test('selectedOption of 1 will update threshold', () async {
      const randomNegOneToPosOne = -0.2;
      const selectedOption = 1;

      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(randomNegOneToPosOne);

      final actual =
          testObject.mutateBasedOnSelectedOption(selectedOption, perceptron);

      expect(actual, perceptron.copyWith(threshold: randomNegOneToPosOne));

      verifyNever(() => mockNumberGenerator.randomNegOneToPosOne);
      verify(() => mockNumberGenerator.nextDouble);
      verifyNoMoreInteractions(mockNumberGenerator);
    });

    test('selectedOption of 2 or more will update proper weight', () async {
      const randomNegOneToPosOne = -0.99;

      final selectedOptions = List.generate(3, (index) => index + 2);

      for (final selectedOption in selectedOptions) {
        when(() => mockNumberGenerator.randomNegOneToPosOne)
            .thenReturn(randomNegOneToPosOne);

        final actual =
            testObject.mutateBasedOnSelectedOption(selectedOption, perceptron);

        final newWeights = List<double>.from(weights);
        newWeights[selectedOption - 2] = randomNegOneToPosOne;
        expect(actual, perceptron.copyWith(weights: newWeights));

        verifyNever(() => mockNumberGenerator.nextDouble);
        verify(() => mockNumberGenerator.randomNegOneToPosOne);
        verifyNoMoreInteractions(mockNumberGenerator);
      }
    });
  });

  group('selectMutationOption', () {
    const justUnderNextThresholdValue = 0.19;
    const selectionProbability = 1.0 / 5;

    // There are 5 total options.
    // 0 => bias
    // 1 => threshold
    // 2-4 => weights
    // So, each bucket is 1.0 / 5 ==> 0.2

    test('selects proper option', () async {
      final expectedValues =
          List.generate(weights.length + 2, (index) => index);

      for (final expectedValue in expectedValues) {
        final randomlyGeneratedValue = justUnderNextThresholdValue +
            (expectedValue * selectionProbability);
        when(() => mockNumberGenerator.nextDouble)
            .thenReturn(randomlyGeneratedValue);

        final actual = testObject.selectMutationOption(perceptron);
        expect(actual, expectedValue);

        verify(() => mockNumberGenerator.nextDouble);
        verifyNoMoreInteractions(mockNumberGenerator);
      }
    });
  });
}
