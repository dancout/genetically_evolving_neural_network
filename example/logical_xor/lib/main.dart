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

  Axis topPerformingDisplayAxis = Axis.horizontal;
  final topPerformerKey = GlobalKey();

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

    parentKeys = List.generate(config.numParents, (index) => GlobalKey());

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
    // Run after the widget has completed building
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final updatedAxis = _determineUpdatedTopPerformingDisplayAxis(
        topPerformerKey: topPerformerKey,
        topPerformingDisplayAxis: topPerformingDisplayAxis,
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
                        Flex(
                          direction: topPerformingDisplayAxis,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (topPerformingDisplayAxis == Axis.vertical)
                              const SizedBox(height: 24.0),
                            _showTopScoringParentsSection(),
                            if (topPerformingDisplayAxis == Axis.vertical)
                              const SizedBox(height: 12.0),
                            if (topPerformingDisplayAxis == Axis.horizontal)
                              const SizedBox(width: 24.0),
                            _showTopPerformerSection(
                                generation.population.topScoringEntity),
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
                        _showInputsAnswersAndGuesses(
                            generation.population.topScoringEntity),
                        const SizedBox(height: 24),
                        ..._showPopulationPerceptronMaps(mediaQuerySize),
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

  Axis _determineUpdatedTopPerformingDisplayAxis({
    required Axis topPerformingDisplayAxis,
    required GlobalKey topPerformerKey,
  }) {
    final List<Size> parentSizes = [];

    for (final globalKey in parentKeys) {
      final size = globalKey.currentContext?.size;
      if (size != null) {
        parentSizes.add(size);
      }
    }

    final double maxHeight = [
      topPerformerKey.currentContext?.size?.height,
      ...parentSizes.map((parentSize) => parentSize.height),
    ].fold(0, (previousValue, element) {
      final currValue = (element ?? 0);
      return (previousValue > currValue) ? previousValue : currValue;
    });

    final double maxWidth = [
      topPerformerKey.currentContext?.size?.width,
      ...parentSizes.map((parentSize) => parentSize.width),
    ].fold(0, (previousValue, element) {
      final currValue = (element ?? 0);
      return (previousValue > currValue) ? previousValue : currValue;
    });

    if (maxHeight > maxWidth) {
      return Axis.horizontal;
    } else {
      return Axis.vertical;
    }
  }

  Column _showTopPerformerSection(GENNEntity entity) {
    return Column(
      children: [
        const Text(
          ' Top Performing Neural Network',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        uiHelper.showPerceptronMapWithScore(
          entity: entity,
          showLabels: true,
          key: topPerformerKey,
        ),
      ],
    );
  }

  Widget _showTopScoringParentsSection() {
    final topScoringParents = generation?.population.topScoringEntity.parents;

    // TODO: TRY TO CLEAN ALL THIS UP

    final parentsOfTopPerformerChildren = <Widget>[];
    if (topScoringParents != null) {
      final spaceBetween = (topPerformingDisplayAxis == Axis.vertical)
          ? const SizedBox(
              height: 12.0,
            )
          : const SizedBox(
              width: 12.0,
            );

      for (int i = 0; i < parentKeys.length; i++) {
        parentsOfTopPerformerChildren.add(
          uiHelper.showPerceptronMapWithScore(
            entity: topScoringParents[i],
            showLabels: true,
            key: parentKeys[i],
          ),
        );
        parentsOfTopPerformerChildren.add(spaceBetween);
      }
      // We don't want the last spacebetween object
      parentsOfTopPerformerChildren.removeLast();
    }

    final parentsOfTopPerformer = Flex(
      direction: topPerformingDisplayAxis,
      children: parentsOfTopPerformerChildren,
    );
    final parentsOfTopPerformerWrapper = Column(
      children: [
        if (topScoringParents != null)
          const Text(
            'Parents of Top Performing Neural Network',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        parentsOfTopPerformer,
      ],
    );
    return parentsOfTopPerformerWrapper;
  }

  Widget _showInputsAnswersAndGuesses(GENNEntity entity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        uiHelper.showLogicalInputs(),
        const SizedBox(width: 12),
        uiHelper.showCorrectAnswers(),
        const SizedBox(width: 12),
        uiHelper.showNeuralNetworkGuesses(
          entity,
        ),
      ],
    );
  }

  List<Widget> _showPopulationPerceptronMaps(Size mediaQuerySize) {
    final generation = this.generation;
    if (generation == null) {
      return [];
    }

    return [
      Text(
        'Entire Population of Neural Networks (${generation.population.entities.length} in total)',
      ),
      const Text(
        'These are chosen as parents to breed the next generation',
        style: TextStyle(fontStyle: FontStyle.italic),
      ),
      uiHelper.perceptronMapDivider,
      SizedBox(
        height: mediaQuerySize.height,
        child: ListView.separated(
          itemBuilder: (_, index) => uiHelper.showPerceptronMapWithScore(
            entity: generation.population.entities[index],
          ),
          itemCount: generation.population.entities.length,
          separatorBuilder: (_, __) => uiHelper.perceptronMapDivider,
        ),
      ),
    ];
  }
}
