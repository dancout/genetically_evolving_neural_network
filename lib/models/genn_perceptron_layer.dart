import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

class GENNPerceptronLayer extends PerceptronLayer {
  const GENNPerceptronLayer({
    required this.gennPerceptrons,
  }) : super(perceptrons: gennPerceptrons);

  final List<GENNPerceptron> gennPerceptrons;
}
