part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [NeuralNetwork.PerceptronLayer].
@JsonSerializable()
class GENNPerceptronLayer extends PerceptronLayer {
  /// An extension of [NeuralNetwork.PerceptronLayer].
  GENNPerceptronLayer({
    required List<GENNPerceptron> perceptrons,
  })  : _gennPerceptrons = perceptrons,
        super(perceptrons: perceptrons) {
    for (var perceptron in _gennPerceptrons) {
      assert(
        perceptron.layer == layer,
        'All Perceptrons within PerceptronLayer must have the same layer.',
      );
    }
  }

  final List<GENNPerceptron> _gennPerceptrons;

  /// The number of the layer within the NeuralNetwork.
  int get layer => _gennPerceptrons.first.layer;

  @override
  List<GENNPerceptron> get perceptrons => _gennPerceptrons;

  @override
  List<Object?> get props => [
        ...super.props,
        _gennPerceptrons,
      ];

  /// Converts the input [json] into a [GENNPerceptronLayer] object.
  factory GENNPerceptronLayer.fromJson(Map<String, dynamic> json) =>
      _$GENNPerceptronLayerFromJson(json);

  /// Converts the [GENNPerceptronLayer] object to JSON.
  @override
  Map<String, dynamic> toJson() => _$GENNPerceptronLayerToJson(this);
}
