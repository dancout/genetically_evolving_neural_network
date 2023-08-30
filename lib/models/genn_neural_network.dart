import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

// TODO: Clean up this file

class GENNNeuralNetwork extends NeuralNetwork {
  GENNNeuralNetwork({
    required super.layers,
    super.guessService,
  });

  factory GENNNeuralNetwork.fromGenes({
    required List<Gene<GENNPerceptron>> genes,
    GuessService? guessService,
  }) {
    // Sort genes first.
    // Assert (here or somewhere) that the layer parameter is not null on ALL GENES

    final layers = <PerceptronLayer>[];

    // Find out how many layers there are
    final expectedLayers = genes.last.value.layer;

    for (int i = 0; i <= expectedLayers; i++) {
      var genesOfLayer = genes
          .where((gene) => gene.value.layer == i)
          .map((e) => e.value)
          .toList();
      layers.add(
        PerceptronLayer(
          perceptrons: genesOfLayer,
        ),
      );
    }

    return GENNNeuralNetwork(
      layers: layers,
      guessService: guessService,
    );
  }
}
