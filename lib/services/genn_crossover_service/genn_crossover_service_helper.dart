part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Used for finding min, max, or in-between layer values on Entity objects.
class GENNCrossoverServiceHelper {
  /// Used for finding min, max, or in-between layer values on Entity objects.
  GENNCrossoverServiceHelper({
    NumberGenerator? numberGenerator,
  }) : numberGenerator = numberGenerator ?? NumberGenerator();

  /// Used to generate random numbers and bools.
  final NumberGenerator numberGenerator;

  /// Returns an [int] somewhere between the input [minValue] and [maxValue].
  int alignMinAndMaxValues({
    required int maxValue,
    required int minValue,
  }) {
    assert(
      maxValue >= minValue,
      'maxValue must be greater than or equal to minValue',
    );

    while (maxValue != minValue) {
      if (numberGenerator.nextBool) {
        // Increment the min value towards the max value
        minValue++;
      } else {
        // Decrement the max value towards the min value
        maxValue--;
      }
    }
    return maxValue;
  }

  /// Returns the max layer value on an Entity from the incoming [parents].
  int maxLayerNum({
    required List<GENNEntity> parents,
  }) {
    return parents.fold(
        0,
        (previousValue, gennEntity) => (previousValue > gennEntity.maxLayerNum)
            ? previousValue
            : gennEntity.maxLayerNum);
  }

  /// Returns the min layer value on an Entity from the incoming [parents].
  int minLayerNum({
    required int maxLayerNum,
    required List<GENNEntity> parents,
  }) {
    return parents.fold(
        maxLayerNum,
        (previousValue, gennEntity) => (previousValue < gennEntity.maxLayerNum)
            ? previousValue
            : gennEntity.maxLayerNum);
  }
}
