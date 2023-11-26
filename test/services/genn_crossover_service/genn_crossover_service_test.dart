import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  const numOutputs = 2;
  const fitnessScore = 1.0;
  const wave = 0;
  final gennGenes = <GENNGene>[];
  final parents = <GENNEntity>[
    GENNEntity(
        gennDna: GENNDNA(gennGenes: gennGenes), fitnessScore: fitnessScore)
  ];
  late GeneMutationService<GENNPerceptron> mockGeneMutationService;
  late GENNCrossoverServiceAlignmentHelper
      mockGennCrossoverServiceAlignmentHelper;
  late GENNCrossoverService testObject;

  setUp(() async {
    mockGeneMutationService = MockGeneMutationService();
    mockGennCrossoverServiceAlignmentHelper =
        MockGENNCrossoverServiceAlignmentHelper();
    testObject = GENNCrossoverService(
      perceptronLayerMutationService: MockPerceptronLayerMutationService(),
      geneMutationService: mockGeneMutationService,
      numOutputs: numOutputs,
      gennCrossoverServiceAlignmentHelper:
          mockGennCrossoverServiceAlignmentHelper,
    );
  });

  group('constructor', () {
    test(
        'throws exception if both PerceptronLayerMutationService is null AND GENNCrossoverServiceAlignmentHelper is null',
        () async {
      expect(
        () => testObject = GENNCrossoverService(
          perceptronLayerMutationService: null,
          geneMutationService: mockGeneMutationService,
          gennCrossoverServiceAlignmentHelper: null,
          numOutputs: numOutputs,
        ),
        throwsException,
      );
    });

    test(
        'does not throw exception if PerceptronLayerMutationService is not null AND GENNCrossoverServiceAlignmentHelper is null',
        () async {
      testObject = GENNCrossoverService(
        perceptronLayerMutationService: MockPerceptronLayerMutationService(),
        geneMutationService: mockGeneMutationService,
        gennCrossoverServiceAlignmentHelper: null,
        numOutputs: numOutputs,
      );
    });
  });

  group('crossover', () {
    test('calls service functions', () async {
      when(() => mockGennCrossoverServiceAlignmentHelper
              .alignNumLayersForParents(parents: parents))
          .thenAnswer((_) async => parents);

      when(() => mockGennCrossoverServiceAlignmentHelper
              .alignGenesWithinLayersForParents(parents: parents))
          .thenAnswer((_) async => parents);

      final actual = await testObject.crossover(
        parents: parents,
        wave: wave,
      );

      expect(
        actual,
        // Empty because we didn't actually pass any GENNGenes in to e crossed
        // over!
        [],
      );
    });
  });
}
