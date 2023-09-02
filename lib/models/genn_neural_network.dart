import 'package:genetically_evolving_neural_network/models/genn_gene.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron_layer.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

class GENNNeuralNetwork extends NeuralNetwork {
  GENNNeuralNetwork({
    required this.gennLayers,
    super.guessService,
  }) : super(layers: gennLayers);

  final List<GENNPerceptronLayer> gennLayers;

  int get numLayers => layers.length;

  factory GENNNeuralNetwork.fromGenes({
    required List<GENNGene> genes,
    GuessService? guessService,
  }) {
    // Declare an empty layers list.
    final layers = <GENNPerceptronLayer>[];

    // Determine how many layers are expected to be in the Neural Network.
    final expectedLayers = genes.fold(0, (previousValue, nextGene) {
      return (previousValue > nextGene.value.layer)
          ? previousValue
          : nextGene.value.layer;
    });

    // Iterate through each expected layer
    for (int i = 0; i <= expectedLayers; i++) {
      // Grab all genes of this layer
      var genesOfLayer = genes
          .where((gene) => gene.value.layer == i)
          .map((e) => e.value)
          .toList();
      // Then add the genes into a PerceptronLayer within the layers list.
      layers.add(
        GENNPerceptronLayer(
          gennPerceptrons: genesOfLayer,
        ),
      );
    }

    return GENNNeuralNetwork(
      gennLayers: layers,
      guessService: guessService,
    );
  }
}
