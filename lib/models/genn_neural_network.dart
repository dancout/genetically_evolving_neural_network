import 'package:genetically_evolving_neural_network/models/genn_gene.dart';
import 'package:genetically_evolving_neural_network/models/genn_perceptron_layer.dart';
import 'package:neural_network_skeleton/neural_network_skeleton.dart';

// TODO: Clean up this file

class GENNNeuralNetwork extends NeuralNetwork {
  GENNNeuralNetwork({
    required this.gennLayers,
    super.guessService,
  }) : super(layers: gennLayers);

  final List<GENNPerceptronLayer> gennLayers;

  int get numLayers => layers.length;

  factory GENNNeuralNetwork.fromGenes({
    // NOTE:  This is of type Gene<GENNPerceptron> instead of GENNGene so that
    //        it is backwards compatible with the GENNFitnessService.
    required List<GENNGene> genes,
    GuessService? guessService,
  }) {
    // Sort genes first.
    // Assert (here or somewhere) that the layer parameter is not null on ALL GENES

    final layers = <GENNPerceptronLayer>[];

    // Find out how many layers there are
    final expectedLayers = genes.last.value.layer;

    for (int i = 0; i <= expectedLayers; i++) {
      var genesOfLayer = genes
          .where((gene) => gene.value.layer == i)
          .map((e) => e.value)
          .toList();
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
