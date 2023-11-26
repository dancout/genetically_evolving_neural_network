import 'dart:math';

import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

class MockGennGeneServiceHelper extends Mock implements GennGeneServiceHelper {}

class MockGennGeneServiceMutationHelper extends Mock
    implements GennGeneServiceMutationHelper {}

class MockNumberGenerator extends Mock implements NumberGenerator {}

class MockPerceptronLayerMutationService extends Mock
    implements PerceptronLayerMutationService {}

class MockGeneMutationService<T> extends Mock
    implements GeneMutationService<T> {}

class MockRandom extends Mock implements Random {}

class MockGennCrossoverServiceHelper extends Mock
    implements GENNCrossoverServiceHelper {}

class MockGennCrossoverServiceAlignmentPerceptronHelper extends Mock
    implements GENNCrossoverServiceAlignmentPerceptronHelper {}
