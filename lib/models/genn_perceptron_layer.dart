part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNPerceptronLayer extends PerceptronLayer {
  GENNPerceptronLayer({
    required this.gennPerceptrons,
  }) : super(perceptrons: gennPerceptrons) {
    final layer = gennPerceptrons.first.layer;
    for (var perceptron in gennPerceptrons) {
      assert(
        perceptron.layer == layer,
        'All Perceptrons within PerceptronLayer must have the same layer.',
      );
    }
  }

  final List<GENNPerceptron> gennPerceptrons;

  /// The number of the layer within the NeuralNetwork.
  int get layer => gennPerceptrons.first.layer;

  @override
  List<Object?> get props => [
        ...super.props,
        gennPerceptrons,
      ];
}
