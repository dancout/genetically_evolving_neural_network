TODO: TABLE OF CONTENTS
# Simple Example

## Positive or Negative Number Classifier
This example will guess whether an input is positive or negative.

### Full Working Example
```dart
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
```
# More Complex Examples

You can access the full example code by cloning this package locally, [here](https://github.com/dancout/genetically_evolving_neural_network/tree/main).

## Logical XOR Example
This example will attempt to correctly guess if a set of inputs satisfies Logical XOR - meaning one and only one input should be True (represented by 1.0), and all other inputs should be False (represented by 0.0).

You can see all logical xor files [here](https://github.com/dancout/genetically_evolving_neural_network/tree/main/example/full_visual_example/lib/fitness_services/logical_xor).

![logical_xor](https://github.com/dancout/genetically_evolving_neural_network/assets/5490028/0737a473-5c0f-428c-afba-016fc381a9a9)

### logical_xor_fitness_service.dart
This file contains your custom `FitnessService` that will reward correctly guessing if a set of inputs satisfies Logical XOR.

```dart
/// This fitness service will be used to score a logical XOR calculator. The
/// Neural Network should only be rewarded for guessing "yes" when there is a
/// single input of 1.0 and both other inputs are 0.
class LogicalXORGENNVisualizationFitnessService extends GENNFitnessService {
  /// This function will calculate a fitness score after guessing with every
  /// input within [LogicalXORGENNVisualizationFitnessService.inputList] on the input
  /// [neuralNetwork].
  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Collect all the guesses from this NeuralNetwork
    // NOTE:  getNeuralNetworkGuesses is defined in a different file
    final guesses = getNeuralNetworkGuesses(neuralNetwork: neuralNetwork);

    // Declare a variable to store the sum of all errors
    var errorSum = 0.0;

    // Cycle through each guess to check its validity
    for (int i = 0; i < guesses.length; i++) {
      // Calculate the error from this guess
      final error = (targetOutputsList[i] == guesses[i]) ? 0 : 1;

      // Add this error to the errorSum
      errorSum += error;
    }

    // Calculate the difference between a perfect score (8) and the total
    // errors. A perfect score would mean zero errors with 8 correct answers,
    // meaning a perfect score would be 8.
    final diff = inputList.length - errorSum;

    // To make the better performing Entities stand out more in this population,
    // use the following equation to calculate the FitnessScore.
    //
    // 4 to the power of diff
    return pow(4, diff).toDouble();
  }
}
```

## Image Number Classifier Example
This example will attempt to correctly guess the integer (between 0 and 9) that a pixelated imaged is meant to represent. The inputs are a list of 15 doubles (between 0.0 and 1.0) that effectively represent a 3x5 pixel image.

You can see all Image Number Classifier files [here](https://github.com/dancout/genetically_evolving_neural_network/tree/main/example/full_visual_example/lib/fitness_services/number_classifier).

![number_classifier](https://github.com/dancout/genetically_evolving_neural_network/assets/5490028/d8ad8d24-3ff0-43dd-b74b-4e5ad79ae2f0)

### number_classifier_fitness_service.dart
This file contains your custom `FitnessService` that will reward correctly guessing what integer a pixelated image represents.

```dart
/// This class will be used to score a Number Classifier in tandem with a
/// Neural Network.
class NumberClassifierFitnessService extends GENNFitnessService {
  /// Returns a score that proportional to how many correct guesses this Neural
  /// Network has made across all integers from 0 to 9.
  ///
  /// The scoring function is as follows:
  /// 4 ^ (correct number of guesses)
  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Collect all the guesses from this NeuralNetwork
    // NOTE:  getNeuralNetworkGuesses is defined in a different file
    final guesses = getNeuralNetworkGuesses(neuralNetwork: neuralNetwork);

    // Declare a variable to store the sum of points scored
    int points = 0;

    // Cycle through each guess to check its validity
    for (int i = 0; i < guesses.length; i++) {
      final NaturalNumber targetOutput = targetOutputsList[i];
      final NaturalNumber guessOutput = guesses[i];

      if (targetOutput == guessOutput) {
        // Guessing correctly will give you a point.
        points++;
      }
    }

    // To make the better performing Entities stand out more in this population,
    // use the following equation to calculate the FitnessScore.
    //
    // 4 to the power of points
    return pow(4, points).toDouble();
  }
}
```
