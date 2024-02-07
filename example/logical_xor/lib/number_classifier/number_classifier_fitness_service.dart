import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:logical_xor/number_classifier/natural_number.dart';

/// This class will be used to score a Number Classifier in tandem with a
/// Neural Network.
class NumberClassifierFitnessService
    extends GENNVisualizationExampleFitnessService<PixelImage, NaturalNumber> {
// ================== START OF GENN EXAMPLE RELATED CONTENT =============================
// ================== GENNFitnessService Overrides ======================================

  /// Returns a score that proportional to how many correct guesses this Neural
  /// Network has made across all integers from 0 to 9.
  ///
  /// The scoring function is as follows:
  /// 4 ^ (correct number of guesses)
  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Collect all the guesses from this NeuralNetwork
    final guesses = getNeuralNetworkGuesses(neuralNetwork: neuralNetwork);

    // Declare a variable to store the sum of points scored
    int points = 0;

    // Cycle through each guess to check its validity
    for (int i = 0; i < guesses.length; i++) {
      final NaturalNumber targetOutput = targetOutputsList[i];
      final NaturalNumber guessOutput = guesses[i];

      if (targetOutput == guessOutput) {
        // Guessing correctly will give you a point.
        points++;
      }
    }

    // To make the better performing Entities stand out more in this population,
    // use the following equation to calculate the FitnessScore.
    //
    // 4 to the power of points
    return pow(4, points).toDouble();
  }
// ================== END OF GENN EXAMPLE RELATED CONTENT ===============================

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
}
