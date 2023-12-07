import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/perceptron_map/consts.dart';
import 'package:logical_xor/perceptron_map/perceptron_map.dart';
import 'package:logical_xor/perceptron_map/perceptron_map_key.dart';

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
  static const numInitialInputs = 3;

  static const waitTimeBetweenWaves = 100;

  bool autoPlay = true;
  @override
  void initState() {
    final config = GENNGeneticEvolutionConfig(
      populationSize: 40,
      numOutputs: 1,
      mutationRate: 0.05,
      numInitialInputs: numInitialInputs,
      layerMutationRate: 0.10,
      perceptronMutationRate: 0.2,
      // trackParents: true,
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
                color: negativeColor,
              ),
      );

      guessTextWidgets.add(textWidget);
    }
    return Column(
      children: [
        const Text('Guesses'),
        const Text('   '),
        ...guessTextWidgets,
      ],
    );
  }

  Widget showCorrectAnswers() {
    return Column(
      children: [
        const Text('Correct Answers'),
        const Text('   '),
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

  Widget showLogicalInputs() {
    return Column(
      children: [
        const Text('Logical Inputs'),
        const Text(
          'a, b, c',
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        ...LogicalXORFitnessService()
            .logicalInputsList
            .map((e) => Text(e.toString()))
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
        generation.population.topScoringEntity.fitnessScore == target) {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24.0),
              const PerceptronMapKey(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 48.0),
                child: Column(
                  children: [
                    Text(
                      'This Neural Network is meant to "guess" the output of the classic Logical Exclusive OR (XOR) problem.\n'
                      'Given three inputs, it should output a 1 if ONLY a single input is 1. In any other case, output a 0.\n\n'
                      'Each new generation will choose high scoring parents from the previous generation to "breed" together and create new "children", so that the children\'s DNA is a mixture of both parents\' DNA.\n'
                      'Additionally, the genes have a potential to "mutate", similar to mutations of animals in the real world.',
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            'Inputs:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Flexible(
                          child: Text(
                            'These represent real-world-inputs that can be put into your function.',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 50),
                        SizedBox(width: 12.0),
                        Flexible(
                          child: Text(
                            'The temperature of a plate you are touching at a restaurant.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            'BRAIN:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Flexible(
                          child: Text(
                            'This represents where the algorithm is "thinking" or making decisions based on the input it was given. You can think of these colored connections exactly like neurons firing inside your brain.',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 50),
                        SizedBox(width: 12.0),
                        Flexible(
                          child: Text(
                            'OUCH! This plate feels VERY HOT!',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 50,
                          child: Text(
                            'Output:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 12.0),
                        Flexible(
                          child: Text(
                            'This represents the "guess" or decision that the algorithm has made, based on the "thinking" it did in the previous step.',
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(width: 50),
                        SizedBox(width: 12.0),
                        Flexible(
                          child: Text(
                            'Reflexively, you pull your hand away from the hot plate.',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.0),
                  ],
                ),
              ),
              Text(
                'Generation: ${generation.wave.toString()}',
              ),
              if (topScoringParents != null)
                const Text('Parents of Top Performing Neural Network'),
              // if (topScoringParents == null)
              //   const Text('The first generation does not have parents'),
              if (topScoringParents != null)
                Column(
                  children: [
                    showPerceptronMapWithScore(entity: topScoringParents[0]),
                    showPerceptronMapWithScore(entity: topScoringParents[1]),
                  ],
                ),
              const SizedBox(height: 12.0),
              const Text('Top Performing Neural Network'),
              showPerceptronMapWithScore(
                entity: generation.population.topScoringEntity,
                showLabels: true,
              ),
              Text(
                'Target Score: $target',
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          showLogicalInputs(),
                          const SizedBox(width: 12),
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
                Text('Target reached at Generation: $waveTargetFound'),
              const SizedBox(height: 24),
              Text(
                'Entire Population of Neural Networks (${generation.population.entities.length} in total)',
              ),
              const Text(
                'These are chosen as parents to breed the next generation',
              ),
              perceptronMapDivider,
              Flexible(
                child: ListView.separated(
                  itemBuilder: (context, index) => showPerceptronMapWithScore(
                    entity: generation.population.entities[index],
                  ),
                  // itemCount: generation.population.entities.length,
                  itemCount: 14,
                  separatorBuilder: (context, index) => perceptronMapDivider,
                ),
              ),
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

  Widget showPerceptronMapWithScore({
    required Entity<GENNPerceptron> entity,
    bool showLabels = false,
  }) {
    const textWidth = 150.0;

    final veritcalDivider = Container(
      height: 48.0,
      width: circleDiameter,
      color: Colors.grey,
    );
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: weightsColumnWidth + 9 + circleDiameter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Inputs',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              veritcalDivider,
            ],
          ),
        ),
        const Spacer(),
        const Text(
          'BRAIN',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const Spacer(),
        SizedBox(
          width: weightsColumnWidth + 53,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              veritcalDivider,
              const Text(
                'Output',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12.0),
            ],
          ),
        ),
      ],
    );
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showLabels) row,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              PerceptronMap(
                entity: GENNEntity.fromEntity(
                  entity: entity,
                ),
                numInputs: numInitialInputs,
                showLabels: showLabels,
              ),
              if (!showLabels)
                SizedBox(
                  width: textWidth,
                  child: Text(
                    'Score: ${entity.fitnessScore.toString()}',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
          if (showLabels)
            SizedBox(
              width: textWidth,
              child: Text(
                'Score: ${entity.fitnessScore.toString()}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
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
