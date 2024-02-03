import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  const wave = 0;
  const fitnessScore = 1.0;
  const updatedFitnessScore = 2.0;
  const layer = 0;
  const bias = 0.1;
  const updatedBias = 0.9;
  const threshold = 0.2;
  const weights = [0.1];
  const gene = GENNGene(
    value: GENNPerceptron(
      layer: layer,
      bias: bias,
      threshold: threshold,
      weights: weights,
    ),
  );
  final genes = [
    gene,
  ];
  final originalDNA = GENNDNA(
    genes: genes,
  );

  final parents = [
    GENNEntity(dna: originalDNA, fitnessScore: fitnessScore),
    GENNEntity(dna: originalDNA, fitnessScore: fitnessScore),
  ];
  final randomGene = GENNGene(
    value: gene.value.copyWith(
      bias: updatedBias,
    ),
  );
  final randomDNA = GENNDNA(
    genes: [
      randomGene,
    ],
  );
  final superCrossoverEntity = GENNEntity.fromEntity(
    entity: Entity(
      dna: originalDNA,
      fitnessScore: fitnessScore,
    ),
  );

  final updatedEntity = GENNEntity.fromEntity(
    entity: Entity(
      dna: originalDNA,
      fitnessScore: updatedFitnessScore,
    ),
  );

  final secondUpdatedEntity = GENNEntity.fromEntity(
    entity: Entity(
      dna: randomDNA,
      fitnessScore: updatedFitnessScore,
    ),
  );

  late DNAService<GENNPerceptron> mockDnaService;
  late FitnessService mockFitnessService;
  late GeneMutationService<GENNPerceptron> mockGeneMutationService;
  late EntityParentManinpulator<GENNPerceptron> mockEntityParentManinpulator;
  late GENNEntityServiceHelper mockGENNEntityServiceHelper;
  late CrossoverService<GENNPerceptron> mockCrossoverService;

  late GENNEntityService testObject;

  setUp(() async {
    mockDnaService = MockDNAService();
    mockFitnessService = MockGENNFitnessService();
    mockGeneMutationService = MockGeneMutationService();
    mockEntityParentManinpulator = MockEntityParentManipulator();
    mockGENNEntityServiceHelper = MockGENNEntityServiceHelper();
    mockCrossoverService = MockCrossoverService();

    testObject = GENNEntityService(
      dnaService: mockDnaService,
      fitnessService: mockFitnessService,
      geneMutationService: mockGeneMutationService,
      entityParentManinpulator: mockEntityParentManinpulator,
      gennEntityServiceHelper: mockGENNEntityServiceHelper,
      crossoverService: mockCrossoverService,
      superDotCrossover: ({required parents, required wave}) async =>
          superCrossoverEntity,
    );
  });

  group('crossover', () {
    test('calls proper service functions', () async {
      when(() => mockGENNEntityServiceHelper.mutatePerceptronLayersWithinEntity(
          child: superCrossoverEntity)).thenAnswer((_) async => updatedEntity);

      when(() => mockGENNEntityServiceHelper.mutatePerceptronsWithinLayer(
          child: updatedEntity)).thenAnswer((_) async => secondUpdatedEntity);

      final actual = await testObject.crossOver(
        parents: parents,
        wave: wave,
      );

      expect(actual, secondUpdatedEntity);

      verifyInOrder([
        () => mockGENNEntityServiceHelper.mutatePerceptronLayersWithinEntity(
            child: superCrossoverEntity),
        () => mockGENNEntityServiceHelper.mutatePerceptronsWithinLayer(
            child: updatedEntity),
      ]);
    });
  });
}
