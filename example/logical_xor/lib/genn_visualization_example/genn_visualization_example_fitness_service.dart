import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example.dart';

/// Represents a wrapper class that extends [GENNFitnessService] and implements
/// [GENNVisualizationExample].
class GENNVisualizationExampleFitnessService extends GENNFitnessService
    implements GENNVisualizationExample {
  @override
  Future<double> gennScoringFunction(
      {required GENNNeuralNetwork neuralNetwork}) {
    throw UnimplementedError();
  }

  @override
  List<List<double>> getNeuralNetworkGuesses(
      {required GENNNeuralNetwork neuralNetwork}) {
    throw UnimplementedError();
  }

  @override
  double? get highestPossibleScore => throw UnimplementedError();

  @override
  List<List<double>> get inputsList => throw UnimplementedError();

  @override
  List<String> get readableInputList => throw UnimplementedError();

  @override
  List<String> get readableTargetList => throw UnimplementedError();

  @override
  double? get targetFitnessScore => throw UnimplementedError();

  @override
  List<List<double>> get targetOutputsList => throw UnimplementedError();

  @override
  String convertToReadableString(List<double> valueList) {
    throw UnimplementedError();
  }
}
