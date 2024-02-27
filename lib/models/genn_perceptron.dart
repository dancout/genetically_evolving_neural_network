part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [NeuralNetwork.Perceptron] that additionally tracks which
/// layer it is a part of.
@JsonSerializable()
class GENNPerceptron extends Perceptron {
  const GENNPerceptron({
    required this.layer,
    required super.bias,
    required super.threshold,
    required super.weights,
  });

  /// The [PerceptronLayer] this object is a part of within the [NeuralNetwork].
  final int layer;

  GENNPerceptron copyWith({
    int? layer,
    double? bias,
    double? threshold,
    List<double>? weights,
  }) {
    return GENNPerceptron(
      layer: layer ?? this.layer,
      bias: bias ?? this.bias,
      threshold: threshold ?? this.threshold,
      weights: weights ?? this.weights,
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        layer,
      ];

  /// Converts the input [json] into a [GENNPerceptron] object.
  factory GENNPerceptron.fromJson(Map<String, dynamic> json) =>
      _$GENNPerceptronFromJson(json);

  /// Converts the [GENNPerceptron] object to JSON.
  @override
  Map<String, dynamic> toJson() => _$GENNPerceptronToJson(this);
}
