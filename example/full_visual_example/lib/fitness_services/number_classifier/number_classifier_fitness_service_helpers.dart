import 'dart:math';

import 'package:flutter/material.dart';
import 'package:full_visual_example/fitness_services/number_classifier/natural_number.dart';
import 'package:full_visual_example/visualization_helpers/genn_visualization_example/visualization_example_genn_fitness_service.dart';

/// Responsible for implementing the functions described in
/// [VisualizationExampleGENNFitnessService] with respect to the Number
/// Classifier example.
mixin NumberClassifierFitnessServiceHelpers
    on VisualizationExampleGENNFitnessService<PixelImage, NaturalNumber> {
  @override
  String convertToReadableString(NaturalNumber value) {
    return NaturalNumber.values.indexOf(value).toString();
  }

  @override
  double? get highestPossibleScore =>
      pow(4, NaturalNumber.values.length).toDouble();

  @override
  List<PixelImage> get inputList => NaturalNumber.values
      .map(
        (naturalNumber) => naturalNumber.asPixelImage(),
      )
      .toList();

  /// Returns a list of the integers 0 to 9 represented as pixels on a grid.
  @override
  List<Widget> get readableInputList {
    const tileSideLength = 3.4; // Hardcoded to look nice on the page

    // Creates a Grid View representation of the Natural Number to input
    return inputList.map((logicalInput) {
      return Padding(
        padding: const EdgeInsets.all(1.5),
        child: Container(
          color: Colors.blue.withOpacity(0.2),
          child: SizedBox(
            width: tileSideLength * 3,
            height: tileSideLength * 5,
            child: Padding(
              padding: const EdgeInsets.all(0.5),
              child: GridView.count(
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 1.0,
                crossAxisCount: 3,
                children: List.generate(
                  logicalInput.pixels.length,
                  (index) => Container(
                    color: Colors.black.withOpacity(
                      logicalInput.pixels[index],
                    ),
                    height: tileSideLength,
                    width: tileSideLength,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  List<Widget> get readableTargetList => targetOutputsList
      .map(
        (targetOutput) => Text(
          convertToReadableString(targetOutput),
        ),
      )
      .toList();

  @override
  List<NaturalNumber> get targetOutputsList => NaturalNumber.values;

  @override
  int get numInitialInputs => NaturalNumberExtension.numPixels;

  @override
  int get numOutputs => NaturalNumber.values.length;

  /// Returns the index of the guess with the highest confidence.
  ///
  @override
  NaturalNumber convertGuessToOutputType({required List<double> guess}) {
    // Declare a list to hold the indices of the highest confidence guesses
    final List<int> listOfHighestConfidenceIndices = [];

    // Declare our initial confidence of 0, because we're not confident in
    // anything yet.
    double confidence = 0;

    // Loop through each guess
    for (int i = 0; i < guess.length; i++) {
      if (guess[i] > confidence) {
        // If the current guess has a higher confidence, set it accordingly
        confidence = guess[i];
        // Clear any previous indicies of highest confidence
        listOfHighestConfidenceIndices.clear();
        listOfHighestConfidenceIndices.add(i);
      } else if (guess[i] == confidence) {
        // If the current guess has the same confidence as the current highest
        listOfHighestConfidenceIndices.add(i);
      }
    }

    // Choose an index if there were any ties.
    int highestConfidenceIndex = accountForGuessTies(
      listOfHighestConfidenceIndices: listOfHighestConfidenceIndices,
    );

    return NaturalNumberExtension.parse(
      number: highestConfidenceIndex,
    );
  }

  @override
  List<double> convertInputToNeuralNetworkInput({
    required PixelImage input,
  }) {
    return input.pixels;
  }

  @override
  String get diagramKeyTitle => 'Number Classifier Description';

  @override
  String get diagramKeyDescription =>
      'This Neural Network is meant to "guess" the value of a number shown in the form of a pixelated image.\n'
      'Using each pixel as an input to the Neural Network, it should be able to guess which positive, natural number between 0 and 9 is being shown.\n\n'
      'Each new generation will choose high scoring parents from the previous generation to "breed" together and create new "children", so that the children\'s DNA is a mixture of both parents\' DNA.\n'
      'Additionally, the genes have a potential to "mutate", similar to mutations of animals in the real world.';
}
