part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// An extension of [NeuralNetwork].
@JsonSerializable()
class GENNNeuralNetwork extends NeuralNetwork {
  /// An extension of [NeuralNetwork].
  GENNNeuralNetwork({
    required List<GENNPerceptronLayer> layers,
    super.guessService,
  })  : _gennLayers = layers,
        super(layers: layers);

  final List<GENNPerceptronLayer> _gennLayers;

  /// Returns a [GENNNeuralNetwork] constructed from the input [genes].
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
          perceptrons: perceptronsOfLayer,
        ),
      );
    }

    return GENNNeuralNetwork(
      layers: layers,
      guessService: guessService,
    );
  }

  @override
  List<GENNPerceptronLayer> get layers => _gennLayers;

  /// The number of [GennperceptronsLayer]s within this [GENNNeuralNetwork].
  int get numLayers => _gennLayers.length;

  /// Converts the input [json] into a [GENNNeuralNetwork] object.
  factory GENNNeuralNetwork.fromJson(Map<String, dynamic> json) =>
      _$GENNNeuralNetworkFromJson(json);

  /// Converts the [GENNNeuralNetwork] object to JSON.
  @override
  Map<String, dynamic> toJson() => _$GENNNeuralNetworkToJson(this);
}
