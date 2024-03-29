import 'package:flutter/material.dart';
import 'package:full_visual_example/visualization_helpers/genn_visualization_example/visualization_example_genn_fitness_service.dart';
import 'package:full_visual_example/visualization_helpers/perceptron_map/consts.dart';
import 'package:full_visual_example/visualization_helpers/perceptron_map/perceptron_map.dart';
import 'package:full_visual_example/visualization_helpers/perceptron_map/perceptron_map_key.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Responsible for showing various parts of the Example UI that aren't related
/// to how the Genetically Evolving Neural Network works.
class UIHelper<I, O> {
  UIHelper({
    required this.gennExampleFitnessService,
  });

  final perceptronMapDivider = Container(height: 4, color: Colors.grey);

  final VisualizationExampleGENNFitnessService<I, O> gennExampleFitnessService;

  /// Shows a Column of the correct answers built from
  /// [GENNExampleFitnessService.readableTargetList].
  Widget showCorrectAnswers() {
    return Column(
      children: [
        const Text('Correct Answers'),
        const Text('   '),
        ...gennExampleFitnessService.readableTargetList
      ],
    );
  }

  /// Shows a Column of the inputs to the Neural Network built from
  /// [GENNExampleFitnessService.readableInputList].
  Widget showLogicalInputs() {
    return Column(
      children: [
        const Text('Logical Inputs'),
        const Text(
          'a, b, c...',
          style: TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
        ...gennExampleFitnessService.readableInputList
      ],
    );
  }

  /// Shows a Column of readable Text Widgets build from the outputs of the
  /// Neural Network.
  Widget showNeuralNetworkGuesses(GENNEntity entity) {
    final guesses = gennExampleFitnessService.getNeuralNetworkGuesses(
      neuralNetwork: GENNNeuralNetwork.fromGenes(
        genes: entity.dna.genes,
      ),
    );

    final guessTextWidgets = [];

    for (int i = 0; i < guesses.length; i++) {
      final guess = guesses[i];
      final readableGuess =
          gennExampleFitnessService.convertToReadableString(guess);
      final readableTarget = gennExampleFitnessService.convertToReadableString(
        gennExampleFitnessService.targetOutputsList[i],
      );
      final textWidget = Text(
        readableGuess,
        style: readableGuess == readableTarget
            ? null
            : const TextStyle(
                color: negativeColor,
                fontWeight: FontWeight.bold,
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

  /// Shows the incoming [entity] as a [PerceptronMap], optionally along with
  /// labels around the Inputs, Brain, and Outputs of the Neural Network.
  Widget showPerceptronMapWithScore({
    required GENNEntity entity,
    bool showLabels = false,
    Key? key,
  }) {
    final veritcalDivider = Container(
      height: 48.0,
      width: circleDiameter,
      color: Colors.grey,
    );
    var row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: weightsColumnWidth + 13 + circleDiameter,
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
          width: weightsColumnWidth + 84,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              veritcalDivider,
              const Text(
                'Output(s)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12.0),
            ],
          ),
        ),
      ],
    );
    return IntrinsicWidth(
      key: key,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            child: Text(
              'Score: ${entity.fitnessScore.toString()}',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showLabels) row,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              PerceptronMap(
                entity: GENNEntity.fromEntity(
                  entity: entity,
                ),
                numInputs: gennExampleFitnessService.numInitialInputs,
                numOutputs: gennExampleFitnessService.numOutputs,
                showLabels: showLabels,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Returns an [Axis] that represents which direction to lay out the parents
  /// of the top performing entity.
  Axis determineUpdatedTopPerformingDisplayAxis({
    required GlobalKey topPerformerKey,
    required List<GlobalKey> parentKeys,
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

  /// Returns a Column containing the [PerceptronMap] of the Top Performing
  /// Entity.
  Column showTopPerformerSection({
    required GENNEntity topScoringEntity,
    required GlobalKey topPerformerKey,
  }) {
    return Column(
      children: [
        const Text(
          ' Top Performing Neural Network',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        showPerceptronMapWithScore(
          entity: topScoringEntity,
          showLabels: true,
          key: topPerformerKey,
        ),
      ],
    );
  }

  /// Returns a Column or Row of the Parents of the Top Performing Entity based
  /// on the incoming [topPerformingDisplayAxis].
  Widget showTopScoringParentsSection({
    required List<GENNEntity>? topScoringParents,
    required Axis topPerformingDisplayAxis,
    required List<GlobalKey> parentKeys,
  }) {
    if (topScoringParents == null) {
      return const SizedBox();
    }

    final parentsOfTopPerformer = <Widget>[];
    final separator = SizedBox(
      height: (topPerformingDisplayAxis == Axis.vertical) ? 12.0 : 0.0,
      width: (topPerformingDisplayAxis == Axis.vertical) ? 0.0 : 12.0,
    );

    for (int i = 0; i < parentKeys.length; i++) {
      parentsOfTopPerformer.add(
        showPerceptronMapWithScore(
          entity: topScoringParents[i],
          showLabels: true,
          key: parentKeys[i],
        ),
      );
      parentsOfTopPerformer.add(separator);
    }
    // We don't want the last spacebetween object
    parentsOfTopPerformer.removeLast();

    return Column(
      children: [
        const Text(
          'Parents of Top Performing Neural Network',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        Flex(
          direction: topPerformingDisplayAxis,
          children: parentsOfTopPerformer,
        ),
      ],
    );
  }

  /// Shows the Neural Network inputs, the guesses, and the correct answers all
  /// side-by-side.
  Widget showInputsAnswersAndGuesses(GENNEntity entity) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        showLogicalInputs(),
        const SizedBox(width: 12),
        showCorrectAnswers(),
        const SizedBox(width: 12),
        showNeuralNetworkGuesses(
          entity,
        ),
      ],
    );
  }

  /// Shows the incoming [generation]'s entity population as [PerceptronMap]
  /// objects.
  List<Widget> showPopulationPerceptronMaps({
    required Size mediaQuerySize,
    required GENNGeneration? generation,
  }) {
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
      perceptronMapDivider,
      SizedBox(
        height: mediaQuerySize.height,
        child: ListView.separated(
          itemBuilder: (_, index) => showPerceptronMapWithScore(
            entity: generation.population.entities[index],
          ),
          itemCount: generation.population.entities.length,
          separatorBuilder: (_, __) => perceptronMapDivider,
        ),
      ),
    ];
  }

  /// Shows the Top Performing Entity and its Parents in either a Column or Row,
  /// depending on the incoming [topPerformingDisplayAxis].
  Widget showTopPerformerAndParentsSection({
    required GENNGeneration generation,
    required Axis topPerformingDisplayAxis,
    required List<GlobalKey> parentKeys,
    required GlobalKey topPerformerKey,
  }) {
    return Flex(
      direction: topPerformingDisplayAxis,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (topPerformingDisplayAxis == Axis.vertical)
          const SizedBox(height: 24.0),
        showTopScoringParentsSection(
          topScoringParents: generation.population.topScoringEntity.parents,
          topPerformingDisplayAxis: topPerformingDisplayAxis,
          parentKeys: parentKeys,
        ),
        if (topPerformingDisplayAxis == Axis.vertical)
          const SizedBox(height: 12.0),
        if (topPerformingDisplayAxis == Axis.horizontal)
          const SizedBox(width: 24.0),
        showTopPerformerSection(
          topScoringEntity: generation.population.topScoringEntity,
          topPerformerKey: topPerformerKey,
        ),
      ],
    );
  }

  Widget showDiagramKey({
    required Size mediaQuerySize,
  }) {
    return SizedBox(
      width: mediaQuerySize.width / 2,
      child: Column(
        children: [
          const PerceptronMapKey(),
          const SizedBox(height: 12.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48.0),
            child: Column(
              children: [
                const Text(
                  'Diagram Descriptions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: keyTextWidth,
                      child: Text(
                        'bias:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        'Every thought we have has at least a little bit of bias, swaying our decision making process. For instance, when choosing colors for this page, I chose red for negative (obviously), and then blue for positive. I could have also chosen black, green, or anything else.',
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    SizedBox(width: keyTextWidth),
                    SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        'I can\'t explain it, but I just kinda like blue.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: keyTextWidth,
                      child: Text(
                        'weight:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        'Weight represents how strongly a particular factor might influence our thinking.',
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    SizedBox(width: keyTextWidth),
                    SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        'It being 9PM will influence me to turn the lights on moreso than the fact that it is winter outside.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: keyTextWidth,
                      child: Text(
                        'threshold:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        'A neuron in your brain is not actually triggered until a certain limit, or threshold, has been breached. Once this limit has been met, the neuron activates and you react to the stimuli. The lower the threshold, the more quickly you will react.',
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    SizedBox(width: keyTextWidth),
                    SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        'Pain receptors in your finger do not really care if you press against a needle, until the skin is broken and then YOU REALLY KNOW IT.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Section Descriptions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: keyTextWidth,
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
                const Row(
                  children: [
                    SizedBox(width: keyTextWidth),
                    SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        'The temperature of a plate you are touching at a restaurant.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: keyTextWidth,
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
                const Row(
                  children: [
                    SizedBox(width: keyTextWidth),
                    SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        'OUCH! This plate feels VERY HOT!',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: keyTextWidth,
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
                const Row(
                  children: [
                    SizedBox(width: keyTextWidth),
                    SizedBox(width: 12.0),
                    Flexible(
                      child: Text(
                        'Reflexively, you pull your hand away from the hot plate.',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                perceptronMapDivider,
                const SizedBox(height: 12.0),
                Text(
                  gennExampleFitnessService.diagramKeyTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                Text(
                  gennExampleFitnessService.diagramKeyDescription,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
