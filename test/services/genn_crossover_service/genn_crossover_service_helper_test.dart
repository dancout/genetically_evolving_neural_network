import 'package:flutter_test/flutter_test.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  late NumberGenerator mockNumberGenerator;
  late GENNCrossoverServiceHelper testObject;

  setUp(() async {
    mockNumberGenerator = MockNumberGenerator();

    testObject = GENNCrossoverServiceHelper(
      numberGenerator: mockNumberGenerator,
    );
  });

  group('alignMinAndMaxValues', () {
    test('throws assertion error when maxValue is less than to minValue',
        () async {
      const minValue = 10;
      final maxValues =
          List.generate(minValue, (index) => minValue - (index + 1));

      for (final maxValue in maxValues) {
        expect(
          () => testObject.alignMinAndMaxValues(
              maxValue: maxValue, minValue: minValue),
          throwsAssertionError,
        );
      }
    });

    test(
        'will increment value as long as nextBool returns true and maxValue != minValue',
        () {
      const minValue = 1;
      const maxValue = 5;

      when(() => mockNumberGenerator.nextBool).thenReturn(true);

      final actual = testObject.alignMinAndMaxValues(
          maxValue: maxValue, minValue: minValue);

      expect(actual, maxValue);
      verify(() => mockNumberGenerator.nextBool).called(4);
    });

    test(
        'will decrement value as long as nextBool returns false and maxValue != minValue',
        () {
      const minValue = 1;
      const maxValue = 5;

      when(() => mockNumberGenerator.nextBool).thenReturn(false);

      final actual = testObject.alignMinAndMaxValues(
          maxValue: maxValue, minValue: minValue);

      expect(actual, minValue);
      verify(() => mockNumberGenerator.nextBool).called(4);
    });

    test(
        'will lean toward maxValue when true is returned more often from nextBool',
        () async {
      const minValue = 1;
      const maxValue = 5;

      final nextBools = [true, true, false, true];
      const expectedValue = 4;

      when(() => mockNumberGenerator.nextBool)
          .thenAnswer((invocation) => nextBools.removeAt(0));

      final actual = testObject.alignMinAndMaxValues(
          maxValue: maxValue, minValue: minValue);

      expect(actual, expectedValue);
      verify(() => mockNumberGenerator.nextBool).called(4);
    });

    test(
        'will lean toward minValue when true is returned more often from nextBool',
        () async {
      const minValue = 1;
      const maxValue = 5;

      final nextBools = [false, false, false, true];
      const expectedValue = 2;

      when(() => mockNumberGenerator.nextBool)
          .thenAnswer((invocation) => nextBools.removeAt(0));

      final actual = testObject.alignMinAndMaxValues(
          maxValue: maxValue, minValue: minValue);

      expect(actual, expectedValue);
      verify(() => mockNumberGenerator.nextBool).called(4);
    });

    test(
        'will be centered between minValue and maxValue when true and false are returned equally from nextBool',
        () async {
      const minValue = 1;
      const maxValue = 5;

      final nextBools = [true, false, true, false];
      const expectedValue = 3;

      when(() => mockNumberGenerator.nextBool)
          .thenAnswer((invocation) => nextBools.removeAt(0));

      final actual = testObject.alignMinAndMaxValues(
          maxValue: maxValue, minValue: minValue);

      expect(actual, expectedValue);
      verify(() => mockNumberGenerator.nextBool).called(4);
    });
  });

  group('maxLayerNum', () {
    const fitnessScore = 1.0;
    const bias = 0.1;
    const threshold = 0.1;
    const weights = [1.0];
    test('returns expected maximum layer value', () async {
      final maxLayerNums = List.generate(10, (index) => index);

      for (int maxLayerNum in maxLayerNums) {
        final layerNums = List.generate(maxLayerNum + 1, (index) => index)
          ..shuffle();

        final List<GENNGene> gennGenes = [];

        for (int layer in layerNums) {
          gennGenes.add(
            GENNGene(
              value: GENNPerceptron(
                layer: layer,
                bias: bias,
                threshold: threshold,
                weights: weights,
              ),
            ),
          );
        }

        final gennEntity = GENNEntity(
          gennDna: GENNDNA(gennGenes: gennGenes),
          fitnessScore: fitnessScore,
        );

        final parents = [
          gennEntity,
          gennEntity,
        ];

        final actual = testObject.maxLayerNum(parents: parents);
        expect(actual, maxLayerNum);
      }
    });

    test('returns expected minimum layer value', () async {
      const maxValue = 10;
      final minLayerNums = List.generate(maxValue + 1, (index) => index);

      for (int minLayerNum in minLayerNums) {
        final layerNums = List.generate(minLayerNum + 1, (index) => index)
          ..shuffle();

        final List<GENNGene> gennGenes = [];

        for (int layer in layerNums) {
          gennGenes.add(
            GENNGene(
              value: GENNPerceptron(
                layer: layer,
                bias: bias,
                threshold: threshold,
                weights: weights,
              ),
            ),
          );
        }

        final gennEntity = GENNEntity(
          gennDna: GENNDNA(gennGenes: gennGenes),
          fitnessScore: fitnessScore,
        );

        final parents = [
          gennEntity,
          gennEntity,
        ];

        final actual = testObject.minLayerNum(
          maxLayerNum: maxValue,
          parents: parents,
        );

        expect(actual, minLayerNum);
      }
    });
  });
}
