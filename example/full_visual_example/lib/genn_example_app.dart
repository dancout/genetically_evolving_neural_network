import 'package:flutter/material.dart';
import 'package:full_visual_example/diagram_key.dart';
import 'package:full_visual_example/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:full_visual_example/ui_helper.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// This class houses an example app to visually display how the incoming
/// [GENNVisualizationExampleFitnessService] works.
class GENNExampleApp extends StatefulWidget {
  /// This class houses an example app to visually display how the incoming
  /// [GENNVisualizationExampleFitnessService] works.
  const GENNExampleApp({
    required this.gennVisualizationExampleFitnessService,
    super.key,
  });

  /// Represents the FitnessService used to drive this GENN example.
  final GENNVisualizationExampleFitnessService
      gennVisualizationExampleFitnessService;

  @override
  State<GENNExampleApp> createState() => _GENNExampleAppState();
}

class _GENNExampleAppState extends State<GENNExampleApp> {
  // ================== START OF GENN EXAMPLE RELATED CONTENT =============================
  /// Represents the FitnessService used to drive this GENN example.
  /// NOTE: This is an extension of [GENNFitnessService]. It contains additional
  ///       funcitons to help with visualizing this example.
  late final GENNVisualizationExampleFitnessService gennExampleFitnessService;

  /// The current generation of Neural Networks.
  GENNGeneration? generation;

  /// The Genetically Evolving Neural Network object.
  late final GENN genn;

  /// Sets the generation value to the next generation on the [GENN] object.
  Future<void> _setNextGeneration() async {
    generation = await genn.nextGeneration();
    setState(() {}); // Update state with the new generation
  }
  // ==================== END OF GENN EXAMPLE RELATED CONTENT =============================

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
    // ================== START OF GENN EXAMPLE RELATED CONTENT ===========================
    // Set the fitness service coming into this example
    gennExampleFitnessService = widget.gennVisualizationExampleFitnessService;

    // Declare a config with specific mutation rates.
    final config = GENNGeneticEvolutionConfig(
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

    // Create the GENN object from the incoming config and fitness service.
    genn = GENN.create(
      config: config,
      fitnessService: gennExampleFitnessService,
    );

    // Initialize the first generation
    _setNextGeneration();
    // ==================== END OF GENN EXAMPLE RELATED CONTENT ===========================

    // Define your UIHelper based on your gennExampleFitnessService
    uiHelper = UIHelper(
      gennExampleFitnessService: gennExampleFitnessService,
    );

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
        parentKeys: parentKeys,
      );

      // Determine whether the axis needs to updated
      bool requiresUpdate = updatedAxis != topPerformingDisplayAxis;

      if (isPlaying) {
        // Sleep for [waitTimeBetweenWaves] during continuous play so that the
        // gradual evolution changes are easier to see.
        await Future.delayed(
            const Duration(milliseconds: waitTimeBetweenWaves));

        // To avoid multiple set states, update the axis with the latest value.
        topPerformingDisplayAxis = updatedAxis;

        // ================== START OF GENN EXAMPLE RELATED CONTENT =======================
        // Set the next Generation to be displayed
        _setNextGeneration();
        // ================== END OF GENN EXAMPLE RELATED CONTENT =========================
      } else if (requiresUpdate) {
        setState(() {
          topPerformingDisplayAxis = updatedAxis;
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
          onPressed: () async {
            if (continuousPlay) {
              setState(() {
                isPlaying = !isPlaying;
              });
            } else {
              await _setNextGeneration();
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
