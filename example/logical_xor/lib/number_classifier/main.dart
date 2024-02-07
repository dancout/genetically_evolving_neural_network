import 'package:flutter/material.dart';
import 'package:logical_xor/genn_example_app.dart';
import 'package:logical_xor/number_classifier/number_classifier_fitness_service.dart';

void main() {
  runApp(
    GENNExampleApp(
      gennVisualizationExampleFitnessService: NumberClassifierFitnessService(),
    ),
  );
}
