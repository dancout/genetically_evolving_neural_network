part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// A wrapper class around the Random class that comes along with additional
/// functionality.
class NumberGenerator {
  NumberGenerator({
    Random? random,
  }) : random = random ?? Random();

  /// Used for random number generation.
  final Random random;

  /// Produces a random double between -1 and 1, exclusively.
  double get randomNegOneToPosOne => (random.nextDouble() * 2) - 1;

  /// Calls random.nextDouble()
  double get nextDouble => random.nextDouble();

  /// Calls random.nextBool()
  bool get nextBool => random.nextBool();

  /// Calls random.next(val)
  int nextInt(int val) {
    return random.nextInt(val);
  }
}
