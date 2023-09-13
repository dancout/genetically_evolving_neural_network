part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNNeuralNetwork extends NeuralNetwork {
  GENNNeuralNetwork({
    required this.gennLayers,
    super.guessService,
  }) : super(layers: gennLayers);

  final List<GENNPerceptronLayer> gennLayers;

  /// The number of [GennperceptronsLayer]s within this [GENNNeuralNetwork].
  int get numLayers => gennLayers.length;

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
      final perceptronsOfLayer = genes
          .where((gene) => gene.value.layer == i)
          .map((e) => e.value)
          .toList();
      // Then add the genes into a PerceptronLayer within the layers list.
      layers.add(
        GENNPerceptronLayer(
          gennPerceptrons: perceptronsOfLayer,
        ),
      );
    }

    return GENNNeuralNetwork(
      gennLayers: layers,
      guessService: guessService,
    );
  }
}
