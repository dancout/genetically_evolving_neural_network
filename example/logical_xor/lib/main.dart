import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/diagram_key.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:logical_xor/logical_xor_fitness_service.dart';
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
  /// The Genetically Evolving Neural Network object.
  late final GENN genn;

  /// The current generation of Neural Networks.
  GENNGeneration? generation;

  /// Whether the example is currently playing forward.
  bool isPlaying = false;

  /// The first wave to contain an Entity that reached the target fitness score.
  int? waveTargetFound;

  /// This represents the time to wait between waves shown on screen during
  /// continuous play.
  static const waitTimeBetweenWaves = 0;

  /// Whether to continuously play on through generations, or only increment by
  /// a single generation after each "play" click.
  bool continuousPlay = true;

  static final LogicalXORFitnessService logicalXORFitnessService =
      LogicalXORFitnessService();
  static final NumberClassifierFitnessService numberClassifierFitnessService =
      NumberClassifierFitnessService();

  /// Represents the FitnessService used to drive this GENN example.
  final GENNVisualizationExampleFitnessService gennExampleFitnessService =
      logicalXORFitnessService;
  // numberClassifierFitnessService;

  /// Used to build components of this example file's UI that are not related to
  /// understanding how the GENN class works.
  late final UIHelper uiHelper;

  /// Determines whether or not to show the Diagram Key on screen.
  bool showDiagramKey = false;

  /// The direction in which to layout the parents of the top performing entity.
  Axis topPerformingDisplayAxis = Axis.horizontal;

  /// The GlobalKey for the top performing entity.
  final topPerformerKey = GlobalKey();

  /// The GlobalKeys for the parents of the top performing entity.
  late final List<GlobalKey> parentKeys;

  @override
  void initState() {
    // Define your UIHelper based on your gennExampleFitnessService
    uiHelper = UIHelper(
      gennExampleFitnessService: gennExampleFitnessService,
    );

    // Declare a config with specific mutation rates.
    final config = GENNGeneticEvolutionConfig(
      populationSize: 250,
      numOutputs: gennExampleFitnessService.numOutputs,
      mutationRate: 0.15,
      numInitialInputs: gennExampleFitnessService.numInitialInputs,
      layerMutationRate: 0.2,
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

    // Set the keys for the parents of the top performing entity.
    parentKeys = List.generate(config.numParents, (index) => GlobalKey());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Run after the widget has completed building
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final updatedAxis = uiHelper.determineUpdatedTopPerformingDisplayAxis(
        topPerformerKey: topPerformerKey,
        topPerformingDisplayAxis: topPerformingDisplayAxis,
        parentKeys: parentKeys,
      );

      // Determine whether the axis needs to updated
      bool requiresUpdate = updatedAxis == topPerformingDisplayAxis;
      // Declare the potential next generation
      GENNGeneration? nextGen;
      if (isPlaying) {
        // Sleep for [waitTimeBetweenWaves] during continuous play so that the
        // gradual evolution changes are easier to see.
        await Future.delayed(
            const Duration(milliseconds: waitTimeBetweenWaves));

        // Create and set the next Generation to be displayed
        nextGen = await genn.nextGeneration();
      }

      // Check if something has changed
      if (isPlaying || requiresUpdate) {
        setState(() {
          topPerformingDisplayAxis = updatedAxis;
          this.generation = nextGen ?? this.generation;
        });
      }
    });

    // Necessary for initial loading of the screen.
    final generation = this.generation;
    if (generation == null) {
      return const CircularProgressIndicator();
    }

    // Check if target has been found.
    if (waveTargetFound == null &&
        generation.population.topScoringEntity.fitnessScore ==
            gennExampleFitnessService.targetFitnessScore) {
      waveTargetFound = generation.wave;
    }

    final mediaQuerySize = MediaQuery.of(context).size;
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: ListView(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showDiagramKey)
                    DiagramKey(
                      gennExampleFitnessService: gennExampleFitnessService,
                    ),
                  SizedBox(
                    width: mediaQuerySize.width / (showDiagramKey ? 2.0 : 1.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Generation: ${generation.wave.toString()}',
                        ),
                        if (gennExampleFitnessService.targetFitnessScore !=
                            null)
                          Text(
                            '(Target Score: ${gennExampleFitnessService.targetFitnessScore})',
                          ),
                        uiHelper.showTopPerformerAndParentsSection(
                          generation: generation,
                          parentKeys: parentKeys,
                          topPerformerKey: topPerformerKey,
                          topPerformingDisplayAxis: topPerformingDisplayAxis,
                        ),
                        if (waveTargetFound != null)
                          Text(
                            'Target reached at Generation: $waveTargetFound',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        uiHelper.showInputsAnswersAndGuesses(
                          generation.population.topScoringEntity,
                        ),
                        const SizedBox(height: 24),
                        ...uiHelper.showPopulationPerceptronMaps(
                          mediaQuerySize: mediaQuerySize,
                          generation: generation,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
        floatingActionButton: _floatingActionButtons(),
      ),
    );
  }

  Widget _floatingActionButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text('${showDiagramKey ? 'Hide' : 'Show'} Diagram Key'),
        Switch.adaptive(
          value: showDiagramKey,
          onChanged: (value) {
            setState(() {
              showDiagramKey = value;
            });
          },
        ),
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
                  generation = value;
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
    );
  }
}
