import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/diagram_key.dart';
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

  /// The current generation of Neural ENtworks.
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
  static const UIHelper uiHelper = UIHelper(numInitialInputs: numInitialInputs);
  @override
  void initState() {
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
    final generation = this.generation;
    if (generation == null) {
      return const CircularProgressIndicator();
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (isPlaying) {
        await Future.delayed(
            const Duration(milliseconds: waitTimeBetweenWaves));
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

    final perceptronMapDivider = Container(height: 4, color: Colors.grey);
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
              const DiagramKey(),
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
                                uiHelper.showGuesses(
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
                    perceptronMapDivider,
                    Flexible(
                      child: ListView.separated(
                        itemBuilder: (context, index) =>
                            uiHelper.showPerceptronMapWithScore(
                          entity: generation.population.sortedEntities[index],
                        ),
                        itemCount: generation.population.entities.length,
                        // itemCount: 16,
                        separatorBuilder: (context, index) =>
                            perceptronMapDivider,
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

  /// Returns the list of guesses (or outputs) from the input [neuralNetwork]
  /// based on the standard set of inputs,
  /// [LogicalXORFitnessService.logicalInputsList].
  List<List<double>> getGuesses({
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

  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Collect all the guesses from this NeuralNetwork
    final guesses = getGuesses(neuralNetwork: neuralNetwork);

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
}
