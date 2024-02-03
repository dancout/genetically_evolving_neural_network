import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:logical_xor/genn_visualization_example/genn_visualization_example_fitness_service.dart';
import 'package:logical_xor/number_classifier/natural_number.dart';

// TODO: could we make this class typed (like NumberClassifierFitnessService<T>)
/// so that we can convert an input list of List<T>, and then we can use
/// NaturalNum directly?

/// This class will be used to score a Number Classifier in tandem with a
/// Neural Network.
class NumberClassifierFitnessService
    extends GENNVisualizationExampleFitnessService {
  @override
  String convertToReadableString(List<double> valueList) {
    return NaturalNumber.values
        .indexOf(
          determineBestGuess(guess: valueList),
        )
        .toString();
  }

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
      final NaturalNumber targetOutput =
          determineBestGuess(guess: targetOutputsList[i]);

      final NaturalNumber guessOutput = determineBestGuess(guess: guesses[i]);

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

  @override
  double? get highestPossibleScore => pow(4, 10).toDouble();

  @override
  List<List<double>> get inputsList =>
      NaturalNumber.values.map((e) => e.asPixels()).toList();

  /// Returns a list of the integers 0 to 9 represented as pixels on a grid.
  @override
  List<Widget> get readableInputList {
    const tileSideLength = 3.4; // Hardcoded to look nice on the page

    // Creates a Grid View representation of the Natural Number to input
    return inputsList.map((logicalInput) {
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
                  logicalInput.length,
                  (index) => Container(
                    color: Colors.black.withOpacity(logicalInput[index]),
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
  List<String> get readableTargetList => targetOutputsList
      .map((targetOutput) => convertToReadableString(targetOutput))
      .toList();

  @override
  List<List<double>> get targetOutputsList =>
      // Convert each NaturalNumber to its "correctGuess" form
      NaturalNumber.values
          .map((naturalNum) => naturalNum.asCorrectGuess)
          .toList();

  /// Returns the index of the guess with the highest confidence.
  ///

  // TODO: Should this go in a separate class, or the enum extension?
  NaturalNumber determineBestGuess({
    required List<double> guess,
  }) {
    final List<int> listOfHighestConfidenceIndices = [0];
    double confidence = 0;
    for (int i = 0; i < guess.length; i++) {
      if (guess[i] > confidence) {
        // If the current guess has a higher confidence, set it accordingly
        confidence = guess[i];
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
  int get numInitialInputs => NaturalNumberExtension.numPixels;

  @override
  int get numOutputs => NaturalNumber.values.length;
}
