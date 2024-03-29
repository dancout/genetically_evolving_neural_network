import 'dart:math';

import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

class MockGennGeneServiceHelper extends Mock implements GennGeneServiceHelper {}

class MockGennGeneServiceMutationHelper extends Mock
    implements GennGeneServiceMutationHelper {}

class MockNumberGenerator extends Mock implements NumberGenerator {}

class MockGeneMutationService<T> extends Mock
    implements GeneMutationService<T> {}

class MockRandom extends Mock implements Random {}

class MockGennCrossoverServiceHelper extends Mock
    implements GENNCrossoverServiceHelper {}

class MockGennCrossoverServiceAlignmentPerceptronHelper extends Mock
    implements GENNCrossoverServiceAlignmentPerceptronHelper {}

class MockGENNCrossoverServiceAlignmentHelper extends Mock
    implements GENNCrossoverServiceAlignmentHelper {}

class MockGENNFitnessService extends Mock implements GENNFitnessService {}

class MockGENNGeneMutationService extends Mock
    implements GENNGeneMutationService {}

class MockDNAService<T> extends Mock implements DNAService<T> {}

class MockCrossoverService<T> extends Mock implements CrossoverService<T> {}

class MockEntityParentManipulator<T> extends Mock
    implements EntityParentManinpulator<T> {}

class MockGENNEntityServiceHelper extends Mock
    implements GENNEntityServiceHelper {}

class MockDNAManipulationService extends Mock
    implements DNAManipulationService {}

class MockPerceptronLayerAlignmentHelper extends Mock
    implements PerceptronLayerAlignmentHelper {}

class MockEntityManipulationService extends Mock
    implements EntityManipulationService {}

class MockEntityManipulationServiceAdditionHelper extends Mock
    implements EntityManipulationServiceAdditionHelper {}
