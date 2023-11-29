import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

void main() {
  test('adds one to input values', () async {
    final config = GENNGeneticEvolutionConfig(
      // populationSize: 20,
      numOutputs: 1,
      mutationRate: 0.05,
      numInitialInputs: 3,
      layerMutationRate: 0.15,
      perceptronMutationRate: 0.25,
    );

    final fitnessService = NeuralNetworkFitnessService();

    final geneticallyEvolvingNeuralNetwork = GENN.create(
      config: config,
      fitnessService: fitnessService,
    );

    // run
    Generation<GENNPerceptron> nextGen;

    for (int i = 0; i < 700; i++) {
      // print('----------- i is:     $i');

      nextGen = await geneticallyEvolvingNeuralNetwork.nextGeneration();
      final topScore = nextGen.population.topScoringEntity.fitnessScore;
      print('top score: $topScore');

      // print('num of layers: $numOfLayers');

      if (topScore >= 262144.01) {
        final asdf = <int>[];

        var numOfLayers = nextGen.population.topScoringEntity.dna.genes.fold(
                0,
                (previousValue, element) =>
                    (previousValue > element.value.layer)
                        ? previousValue
                        : element.value.layer) +
            1;

        for (int i = 0; i < numOfLayers; i++) {
          asdf.add(nextGen.population.topScoringEntity.dna.genes
              .where((element) => element.value.layer == i)
              .length);
        }
        print('num of perceptrons per layer: $asdf');
        print('wave: $i');
        break;
      }
    }
  });
}

class NeuralNetworkFitnessService extends GENNFitnessService {
  @override
  double get nonZeroBias => 0.01;

  @override
  Future<double> gennScoringFunction({
    required GENNDNA gennDna,
  }) async {
    // List<List<double>> logicalInputsList = [
    //   [0.0, 0.0],
    //   [1.0, 0.0],
    //   [0.0, 1.0],
    //   [1.0, 1.0],
    // ];

    // List<List<double>> targetOutputsList = [
    //   [0.0],
    //   [1.0],
    //   [1.0],
    //   [0.0],
    // ];

    List<List<double>> logicalInputsList = [
      [0.0, 0.0, 0.0],
      [0.0, 0.0, 1.0],
      [0.0, 1.0, 0.0],
      [0.0, 1.0, 1.0],
      [1.0, 0.0, 0.0],
      [1.0, 0.0, 1.0],
      [1.0, 1.0, 0.0],
      [1.0, 1.0, 1.0],
    ];

    List<List<double>> targetOutputsList = [
      [0.0],
      [1.0],
      [1.0],
      [0.0],
      [1.0],
      [0.0],
      [0.0],
      [0.0],
    ];

    // int maxLayerNum = gennDna.gennGenes.fold(
    //   0,
    //   (previousValue, gennGene) => (previousValue > gennGene.value.layer)
    //       ? previousValue
    //       : gennGene.value.layer,
    // );

    // for (int i = 0; i < maxLayerNum; i++) {
    //   if (gennDna.gennGenes
    //       .where((element) => element.value.layer == i)
    //       .isEmpty) {
    //     print('check dis');
    //   }
    // }

    final neuralNetwork = GENNNeuralNetwork.fromGenes(
      genes: List<GENNGene>.from(gennDna.gennGenes),
    );

    final errors = <double>[];
    for (int i = 0; i < logicalInputsList.length; i++) {
      final inputs = logicalInputsList[i];

      final guess = neuralNetwork.guess(inputs: inputs);
      final error = (targetOutputsList[i][0] - guess[0]).abs();
      errors.add(error);
    }

    final errorsSum = errors.reduce((value, element) => value + element);
    final diff = 9 - errorsSum;

    return pow(4, diff).toDouble();

    // return rootMeanSquareMethod(
    //   logicalInputsList,
    //   neuralNetwork,
    //   targetOutputsList,
    // );
  }

  double rootMeanSquareMethod(List<List<double>> logicalInputsList,
      GENNNeuralNetwork neuralNetwork, List<List<double>> targetOutputsList) {
    final errors = <double>[];

    for (int i = 0; i < logicalInputsList.length; i++) {
      final inputs = logicalInputsList[i];

      final guess = neuralNetwork.guess(inputs: inputs);
      final error = (targetOutputsList[i][0] - guess[0]).abs();
      errors.add(error);
    }

    final errorsSum = errors.reduce((value, element) => value + element);

    final rootMeanSquare = sqrt(errorsSum / logicalInputsList.length);

    return pow(1.0 - rootMeanSquare, 7).toDouble();
  }
}
