import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// The inputs for this Neural Network, from -1 to 1 in increments of 0.1.
List<double> get inputs => List.generate(10, (index) => index * 0.1)
  ..addAll(List.generate(9, (index) => (index + 1) * -0.1));

/// The scoring function that will be used to evolve entities of a population
class PositiveNumberFitnessService extends GENNFitnessService {
  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Calculate how many correct guesses were made
    return inputs.fold(0, (previousValue, input) {
      final guess = neuralNetwork.guess(inputs: [input])[0];
      // Only add a point if the neural network guesses correctly
      if ((input > 0 && guess > 0) || (input <= 0 && guess == 0)) {
        return previousValue + 1;
      }
      return previousValue;
    }).toDouble();
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Represents the FitnessService used to drive this GENN example.
  final GENNFitnessService fitnessService = PositiveNumberFitnessService();

  /// The current generation of Neural Networks.
  GENNGeneration? generation;

  /// The Genetically Evolving Neural Network object.
  late final GENN genn;

  @override
  void initState() {
    // Declare a config with specific mutation rates.
    final config = GENNGeneticEvolutionConfig(
      populationSize: 20,
      numOutputs: 1,
      mutationRate: 0.1,
      numInitialInputs: 1,
      layerMutationRate: 0.25,
      perceptronMutationRate: 0.4,
    );

    // Create the GENN object from the incoming config and fitness service.
    genn = GENN.create(
      config: config,
      fitnessService: fitnessService,
    );

    // Initialize the first generation
    genn.nextGeneration().then((value) {
      setState(() {
        generation = value;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final generation = this.generation;
    if (generation == null) {
      return const CircularProgressIndicator();
    }

    return MaterialApp(
      title: 'GENN Example',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('generation #: ${generation.wave.toString()}'),
              Text('top score: '
                  '${generation.population.topScoringEntity.fitnessScore} '
                  'out of a possible ${inputs.length}.01'),
              Text('top scoring entity\'s # of layers: '
                  '${generation.population.topScoringEntity.maxLayerNum + 1}'),
              Text('top scoring entity\'s # of perceptrons: '
                  '${generation.population.topScoringEntity.dna.genes.length}'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          label: const Text('Next Generation'),
          onPressed: () {
            // Set the next Generation to be displayed
            genn.nextGeneration().then((value) {
              setState(() {
                this.generation = value;
              });
            });
          },
        ),
      ),
    );
  }
}
