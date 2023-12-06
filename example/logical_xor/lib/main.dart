import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/perceptron_map/perceptron_map.dart';

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
  bool isPlaying = false;
  late final double target;

  late final GENN genn;

  // TODO: This is causing the genetic_evolution import above. Can I make it so
  /// that we don't need to import 2 packages for this?
  Generation<GENNPerceptron>? generation;

  int? waveTargetFound;

  bool autoPlay = true;
  @override
  void initState() {
    final config = GENNGeneticEvolutionConfig(
      numOutputs: 1,
      mutationRate: 0.05,
      numInitialInputs: 3,
      layerMutationRate: 0.15,
      perceptronMutationRate: 0.25,
    );

    final fitnessService = LogicalXORFitnessService();

    target = pow(4, 8) + fitnessService.nonZeroBias;

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

  Widget showGuesses(Entity<GENNPerceptron> entity) {
    final logicalXORFitnessService = LogicalXORFitnessService();
    final guesses = logicalXORFitnessService.getGuesses(
      gennDna: GENNDNA.fromDNA(
        dna: entity.dna,
      ),
    );

    final guessTextWidgets = [];

    for (int i = 0; i < guesses.length; i++) {
      final guess = guesses[i][0];
      final textWidget = Text(
        guess.toString(),
        style: (guess == logicalXORFitnessService.targetOutputsList[i][0])
            ? null
            : const TextStyle(
                color: Colors.red,
              ),
      );

      guessTextWidgets.add(textWidget);
    }
    return Column(
      children: [
        const Text('Guesses'),
        ...guessTextWidgets,
      ],
    );
  }

  Widget showCorrectAnswers() {
    return Column(
      children: [
        const Text('Correct Answer'),
        ...LogicalXORFitnessService()
            .targetOutputsList
            .map(
              (targetValue) => Text(
                targetValue[0].toString(),
              ),
            )
            .toList()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final generation = this.generation;
    if (generation == null) {
      return const CircularProgressIndicator();
    }

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (isPlaying) {
        await Future.delayed(const Duration(milliseconds: 100));
        genn.nextGeneration().then((value) {
          setState(() {
            this.generation = value;
          });
        });
      }
    });

    // Check if target has been found.
    if (waveTargetFound == null &&
        generation.population.topScoringEntity.fitnessScore == target) {
      waveTargetFound = generation.wave;
    }

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              PerceptronMap(
                entity: GENNEntity.fromEntity(
                  entity: generation.population.topScoringEntity,
                ),
              ),
              Text(
                'Target: $target',
              ),
              Text(
                'Wave: ${generation.wave.toString()}',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          showCorrectAnswers(),
                          const SizedBox(width: 12),
                          showGuesses(generation.population.topScoringEntity),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Column(
                    children: [
                      const Text('Top Score'),
                      Text(
                        generation.population.topScoringEntity.fitnessScore
                            .toString(),
                      ),
                    ],
                  ),
                ],
              ),
              if (waveTargetFound != null)
                Text('Target reached at wave: $waveTargetFound'),
              const SizedBox(height: 24),
              // const Text('Entities'),
              // Flexible(
              //   child: ListView(
              //     children: wordRows,
              //   ),
              // ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('AutoPlay: ${autoPlay ? 'On' : 'Off'}'),
            Switch.adaptive(
                value: autoPlay,
                onChanged: (value) {
                  setState(() {
                    autoPlay = value;
                    isPlaying = false;
                  });
                }),
            FloatingActionButton(
              onPressed: () {
                if (autoPlay) {
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
              child: (!autoPlay || !isPlaying)
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

  List<List<double>> getGuesses({
    required GENNDNA gennDna,
  }) {
    // Declare the NeuralNetwork
    final neuralNetwork = GENNNeuralNetwork.fromGenes(
      genes: List<GENNGene>.from(gennDna.gennGenes),
    );

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
  double get nonZeroBias => 0.01;

  @override
  Future<double> gennScoringFunction({
    required GENNDNA gennDna,
  }) async {
    // Collect all the guesses from this NeuralNetwork
    final guesses = getGuesses(gennDna: gennDna);

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
    // 4^(diff)
    return pow(4, diff).toDouble();
  }
}
