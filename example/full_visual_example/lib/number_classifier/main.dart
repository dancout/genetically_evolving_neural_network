import 'package:flutter/material.dart';
import 'package:full_visual_example/genn_example_app.dart';
import 'package:full_visual_example/number_classifier/number_classifier_fitness_service.dart';

void main() {
  runApp(
    GENNExampleApp(
      gennVisualizationExampleFitnessService: NumberClassifierFitnessService(),
    ),
  );
}
