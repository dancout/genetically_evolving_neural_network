import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  const numInitialInputs = 10;
  const layer = 0;
  late GennGeneServiceHelper mockGeneServiceHelper;
  late GENNGeneService testObject;

  setUp(() async {
    mockGeneServiceHelper = MockGennGeneServiceHelper();
    testObject = GENNGeneService(
      numInitialInputs: numInitialInputs,
      gennGeneServiceHelper: mockGeneServiceHelper,
    );

    when(() => mockGeneServiceHelper.randomPerceptron(
        numWeights: numInitialInputs, layer: layer)).thenReturn(
      const GENNPerceptron(
        layer: 0,
        bias: 0,
        threshold: 0,
        weights: [],
      ),
    );
  });

  group('randomGene', () {
    test(
        'calls gennGeneServiceHelper.randomPerceptron with the proper initialLayer and numInitialInputs',
        () async {
      testObject.randomGene();

      verify(
        () => mockGeneServiceHelper.randomPerceptron(
          numWeights: numInitialInputs,
          layer: layer,
        ),
      );
    });
  });

  group('mutateValue', () {
    test('calls gennGeneServiceHelper.mutatePerceptron with input value',
        () async {
      const value = GENNPerceptron(
        layer: 1,
        bias: 1,
        threshold: 1,
        weights: [],
      );

      when(() => mockGeneServiceHelper.mutatePerceptron(perceptron: value))
          .thenReturn(value);

      testObject.mutateValue(value: value);

      verify(() => mockGeneServiceHelper.mutatePerceptron(perceptron: value));
    });

    test('throws when value is null', () async {
      expect(() => testObject.mutateValue(), throwsException);

      verifyZeroInteractions(mockGeneServiceHelper);
    });
  });
}
