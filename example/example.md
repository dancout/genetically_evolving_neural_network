## Logical XOR Example
This example will attempt to correctly guess if a set of inputs satisfies Logical XOR - meaning one and only one input should be 1.0, and all other inputs should be 0.0.

You can access the full example by cloning this package locally, [here](https://github.com/dancout/genetically_evolving_neural_network/tree/main).

### logical_xor_fitness_service.dart
This file contains your custom `FitnessService` that will reward correctly guessing if a set of inputs satisfies Logical XOR.

```dart
import 'dart:math';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This fitness service will be used to score a logical XOR calculator. The
/// output should only return true if a single value is 1.0 and both other
/// values are 0.0. There should be one exclusive positive value! The more
/// correct guesses that a NeuralNetwork makes, the higher its fitness score
/// will be.
class LogicalXORFitnessService extends GENNFitnessService {
  /// The list of logical inputs for your XOR calculator. The possible options
  /// are 0 or 1, effectively true or false.
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

  /// The list of logical outputs for your XOR calculator. These are the
  /// expected outputs respective to the logical inputs.
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

  /// This function will calculate a fitness score after guessing with every
  /// input within [LogicalXORFitnessService.logicalInputsList] on the input
  /// [neuralNetwork].
  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Collect all the guesses from this NeuralNetwork
    final guesses = getNeuralNetworkGuesses(neuralNetwork: neuralNetwork);

    // Declare a variable to store the sum of all errors
    var errorSum = 0.0;

    // Cycle through each guess to check its validity
    for (int i = 0; i < guesses.length; i++) {
      // Calculate the error from this guess
      final error = (targetOutputsList[i][0] - guesses[i][0]).abs();

      // Add this error to the errorSum
      errorSum += error;
    }

    // Calculate the difference between a perfect score (8) and the total
    // errors. A perfect score would mean zero errors with 8 correct answers,
    // meaning a perfect score would be 8.
    final diff = logicalInputsList.length - errorSum;

    // To make the better performing Entities stand out more in this population,
    // use the following equation to calculate the FitnessScore.
    //
    // 4 to the power of diff
    return pow(4, diff).toDouble();
  }

  /// Returns the list of guesses (or outputs) from the input [neuralNetwork]
  /// based on the standard set of inputs,
  /// [LogicalXORFitnessService.logicalInputsList].
  List<List<double>> getNeuralNetworkGuesses({
    required GENNNeuralNetwork neuralNetwork,
  }) {
    // Declare a list of guesses
    List<List<double>> guesses = [];

    // Cycle through each input
    for (int i = 0; i < logicalInputsList.length; i++) {
      // Declare this run's set of inputs
      final inputs = logicalInputsList[i];

      // Make a guess using the NeuralNetwork
      final guess = neuralNetwork.guess(inputs: inputs);

      // Add this guess to the list of guesses
      guesses.add(guess);
    }

    // Return the list of guesses
    return guesses;
  }
}
```
### main.dart
This file contains the logic around setting up this visual example.

```dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/diagram_key.dart';
import 'package:logical_xor/logical_xor_fitness_service.dart';
import 'package:logical_xor/ui_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  /// Whether the example is currently playing forward.
  bool isPlaying = false;

  /// The highest possible fitness score.
  final double targetFitnessScore =
      pow(4, 8) + LogicalXORFitnessService().nonZeroBias;

  /// The Genetically Evolving Neural Network object.
  late final GENN genn;

  /// The current generation of Neural Networks.
  GENNGeneration? generation;

  /// The first wave to contain an Entity that reached the target fitness score.
  int? waveTargetFound;

  /// The number of inputs being fed into the Neural Network.
  static const numInitialInputs = 3;

  /// This represents the time to wait between waves shown on screen during
  /// continuous play.
  static const waitTimeBetweenWaves = 400;

  /// Whether to continuously play on through generations, or only increment by
  /// a single generation after each "play" click.
  bool continuousPlay = true;

  /// Used to build components of this example file's UI that are not related to
  /// understanding how the GENN class works.
  static UIHelper get uiHelper => UIHelper(numInitialInputs: numInitialInputs);
  @override
  void initState() {
    // Declare a config with specific mutation rates.
    final config = GENNGeneticEvolutionConfig(
      populationSize: 40,
      numOutputs: 1,
      mutationRate: 0.05,
      numInitialInputs: numInitialInputs,
      layerMutationRate: 0.10,
      perceptronMutationRate: 0.2,
      trackParents: true,
      // We only care about tracking the parents of the current generation to
      // show on-screen
      generationsToTrack: 1,
    );

    // Create your Genetically Evolving Neural Network object.
    genn = GENN.create(
      config: config,
      fitnessService: LogicalXORFitnessService(),
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
    // Necessary for initial loading of the screen.
    final generation = this.generation;
    if (generation == null) {
      return const CircularProgressIndicator();
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (isPlaying) {
        // Sleep for [waitTimeBetweenWaves] during continuous play so that the
        // gradual evolution changes are easier to see.
        await Future.delayed(
            const Duration(milliseconds: waitTimeBetweenWaves));

        // Create and set the next Generation to be displayed
        genn.nextGeneration().then((value) {
          setState(() {
            this.generation = value;
          });
        });
      }
    });

    // Check if target has been found.
    if (waveTargetFound == null &&
        generation.population.topScoringEntity.fitnessScore ==
            targetFitnessScore) {
      waveTargetFound = generation.wave;
    }

    final topScoringParents = generation.population.topScoringEntity.parents;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              const DiagramKey(numInitialInputs: numInitialInputs),
              SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24.0),
                    if (topScoringParents != null)
                      const Text(
                        'Parents of Top Performing Neural Network',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    if (topScoringParents != null)
                      Column(
                        children: [
                          uiHelper.showPerceptronMapWithScore(
                              entity: topScoringParents[0]),
                          uiHelper.showPerceptronMapWithScore(
                              entity: topScoringParents[1]),
                        ],
                      ),
                    const SizedBox(height: 12.0),
                    const Text(
                      ' Top Performing Neural Network',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Generation: ${generation.wave.toString()}',
                    ),
                    uiHelper.showPerceptronMapWithScore(
                      entity: generation.population.topScoringEntity,
                      showLabels: true,
                    ),
                    Text(
                      'Target Score: $targetFitnessScore',
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Row(
                              children: [
                                uiHelper.showLogicalInputs(),
                                const SizedBox(width: 12),
                                uiHelper.showCorrectAnswers(),
                                const SizedBox(width: 12),
                                uiHelper.showNeuralNetworkGuesses(
                                  generation.population.topScoringEntity,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (waveTargetFound != null)
                      Text('Target reached at Generation: $waveTargetFound'),
                    const SizedBox(height: 24),
                    Text(
                      'Entire Population of Neural Networks (${generation.population.entities.length} in total)',
                    ),
                    const Text(
                      'These are chosen as parents to breed the next generation',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    uiHelper.perceptronMapDivider,
                    Flexible(
                      child: ListView.separated(
                        itemBuilder: (context, index) =>
                            uiHelper.showPerceptronMapWithScore(
                          entity: generation.population.sortedEntities[index],
                        ),
                        itemCount: generation.population.entities.length,
                        // itemCount: 16,
                        separatorBuilder: (context, index) =>
                            uiHelper.perceptronMapDivider,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('ContinuousPlay: ${continuousPlay ? 'On' : 'Off'}'),
            Switch.adaptive(
                value: continuousPlay,
                onChanged: (value) {
                  setState(() {
                    continuousPlay = value;
                    isPlaying = false;
                  });
                }),
            FloatingActionButton(
              onPressed: () {
                if (continuousPlay) {
                  setState(() {
                    isPlaying = !isPlaying;
                  });
                } else {
                  genn.nextGeneration().then((value) {
                    setState(() {
                      this.generation = value;
                    });
                  });
                }
              },
              child: (!continuousPlay || !isPlaying)
                  ? const Icon(Icons.play_arrow)
                  : const Icon(Icons.pause),
            ),
            const SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}
```

### perceptron_map
This directory contains many files, and would bloat this example page further.

You can see the `PerceptronMap` directory [here](https://github.com/dancout/genetically_evolving_neural_network/tree/main/example/logical_xor/lib/perceptron_map).