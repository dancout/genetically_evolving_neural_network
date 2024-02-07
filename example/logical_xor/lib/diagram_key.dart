import 'package:flutter/material.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:logical_xor/perceptron_map/consts.dart';
import 'package:logical_xor/perceptron_map/perceptron_map_key.dart';
import 'package:logical_xor/ui_helper.dart';

class DiagramKey extends StatelessWidget {
  const DiagramKey({
    super.key,
    required this.gennExampleFitnessService,
  });

  final GENNVisualizationExampleFitnessService gennExampleFitnessService;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 2,
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
                UIHelper(
                  gennExampleFitnessService: gennExampleFitnessService,
                ).perceptronMapDivider,
                const SizedBox(height: 12.0),
                // TODO: This needs to come from gennExampleFitnessService
                const Text(
                  'Logical XOR Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'This Neural Network is meant to "guess" the output of the classic Logical Exclusive OR (XOR) problem.\n'
                  'Given three inputs, it should output a 1 if ONLY a single input is 1. In any other case, output a 0 (see table to the right for all Correct Answers).\n\n'
                  'Each new generation will choose high scoring parents from the previous generation to "breed" together and create new "children", so that the children\'s DNA is a mixture of both parents\' DNA.\n'
                  'Additionally, the genes have a potential to "mutate", similar to mutations of animals in the real world.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
