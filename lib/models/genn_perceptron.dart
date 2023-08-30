import 'package:neural_network_skeleton/neural_network_skeleton.dart';

/// An extension of [NeuralNetwork.Perceptron] that additionally tracks which
/// layer it is a part of.
class GENNPerceptron extends Perceptron {
  const GENNPerceptron({
    required this.layer,
    required super.bias,
    required super.threshold,
    required super.weights,
  });

  /// The [PerceptronLayer] this object is a part of within the [NeuralNetwork].
  final int layer;

  @override
  List<Object?> get props => [
        ...super.props,
        layer,
      ];
}
