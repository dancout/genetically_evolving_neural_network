import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/diagram_key.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:logical_xor/number_classifier/number_classifier_fitness_service.dart';
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

  /// The Genetically Evolving Neural Network object.
  late final GENN genn;

  /// The current generation of Neural Networks.
  GENNGeneration? generation;

  /// The first wave to contain an Entity that reached the target fitness score.
  int? waveTargetFound;

  /// This represents the time to wait between waves shown on screen during
  /// continuous play.
  static const waitTimeBetweenWaves = 0;

  /// Whether to continuously play on through generations, or only increment by
  /// a single generation after each "play" click.
  bool continuousPlay = true;

  final GENNVisualizationExampleFitnessService gennExampleFitnessService =
      NumberClassifierFitnessService();

  /// Used to build components of this example file's UI that are not related to
  /// understanding how the GENN class works.
  late final UIHelper uiHelper;

  @override
  void initState() {
    // Define your UIHelper based on your gennExampleFitnessService
    uiHelper = UIHelper(
      gennExampleFitnessService: gennExampleFitnessService,
    );

    // Declare a config with specific mutation rates.
    final config = GENNGeneticEvolutionConfig(
      populationSize: 100,
      numOutputs: gennExampleFitnessService.numOutputs,
      mutationRate: 0.15,
      numInitialInputs: gennExampleFitnessService.numInitialInputs,
      layerMutationRate: 0.4,
      perceptronMutationRate: 0.4,
      trackParents: true,
      // We only care about tracking the parents of the current generation to
      // show on-screen
      generationsToTrack: 1,
    );

    // Create your Genetically Evolving Neural Network object.
    genn = GENN.create(
      config: config,
      fitnessService: gennExampleFitnessService,
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
            gennExampleFitnessService.targetFitnessScore) {
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
              DiagramKey(
                gennExampleFitnessService: gennExampleFitnessService,
              ),
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
                    if (gennExampleFitnessService.targetFitnessScore != null)
                      Text(
                        'Target Score: ${gennExampleFitnessService.targetFitnessScore}',
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
                      Text(
                        'Target reached at Generation: $waveTargetFound',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
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
                          entity: generation.population.entities[index],
                        ),
                        itemCount: generation.population.entities.length,
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
