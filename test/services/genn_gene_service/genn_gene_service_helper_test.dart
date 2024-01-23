import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  const selectedOption = 1;
  const perceptron =
      GENNPerceptron(layer: 0, bias: 0, threshold: 0, weights: []);

  late GennGeneServiceMutationHelper mockGennGeneServiceMutationHelper;
  late NumberGenerator mockNumberGenerator;
  late GennGeneServiceHelper testObject;

  setUp(() async {
    mockGennGeneServiceMutationHelper = MockGennGeneServiceMutationHelper();
    mockNumberGenerator = MockNumberGenerator();
    testObject = GennGeneServiceHelper(
      gennGeneServiceMutationHelper: mockGennGeneServiceMutationHelper,
      numberGenerator: mockNumberGenerator,
    );
  });

  group('mutatePerceptron', () {
    test('calls mutation helper properly', () async {
      when(() => mockGennGeneServiceMutationHelper.selectMutationOption(
          perceptron)).thenAnswer((invocation) => selectedOption);

      when(() => mockGennGeneServiceMutationHelper.mutateBasedOnSelectedOption(
          selectedOption, perceptron)).thenAnswer((invocation) => perceptron);

      final actual = testObject.mutatePerceptron(perceptron: perceptron);
      expect(actual, perceptron);

      verify(() =>
          mockGennGeneServiceMutationHelper.selectMutationOption(perceptron));

      verify(() => mockGennGeneServiceMutationHelper
          .mutateBasedOnSelectedOption(selectedOption, perceptron));

      verifyZeroInteractions(mockNumberGenerator);
    });
  });

  group('randomPerceptron', () {
    test('calls NumberGenerator and returns proper GENNPerceptron', () async {
      const layer = 10;
      const threshold = 0.4;
      const bias = 0.5;
      const firstNumWeight = -0.1;
      const secondNumWeight = 0.8;

      const randomWeights = [firstNumWeight, secondNumWeight];
      final numWeights = randomWeights.length;

      final randomNums = [bias, ...randomWeights];
      final expectedRandomNumCalls = randomNums.length;

      when(() => mockNumberGenerator.randomNegOneToPosOne)
          .thenAnswer((invocation) => randomNums.removeAt(0));

      when(() => mockNumberGenerator.nextDouble).thenReturn(threshold);

      const expected = GENNPerceptron(
          layer: layer,
          bias: bias,
          threshold: threshold,
          weights: [firstNumWeight, secondNumWeight]);
      final actual =
          testObject.randomPerceptron(numWeights: numWeights, layer: layer);

      expect(actual, expected);

      verify(() => mockNumberGenerator.randomNegOneToPosOne)
          .called(expectedRandomNumCalls);
      verify(() => mockNumberGenerator.nextDouble);
    });

    test('throws assertion error when numWeights are less than or equal to 0',
        () async {
      final numWeightsValues = List.generate(10, (index) => index * -1);
      const layer = 0;

      for (final value in numWeightsValues) {
        expect(
          () => testObject.randomPerceptron(numWeights: value, layer: layer),
          throwsAssertionError,
        );
      }
    });
  });
}
