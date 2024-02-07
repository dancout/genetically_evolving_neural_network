import 'package:flutter/material.dart';
import 'package:logical_xor/genn_example_app.dart';
import 'package:logical_xor/logical_xor/logical_xor_fitness_service.dart';

void main() {
  runApp(
    GENNExampleApp(
      gennVisualizationExampleFitnessService: LogicalXORFitnessService(),
    ),
  );
}
