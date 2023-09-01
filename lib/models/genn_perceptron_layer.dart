import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

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
}
