import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  const fitnessScore = 1.0;
  const wave = 0;
  final gennGenes = <GENNGene>[];
  final parents = <GENNEntity>[
    GENNEntity(dna: GENNDNA(genes: gennGenes), fitnessScore: fitnessScore)
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
      geneMutationService: mockGeneMutationService,
      gennCrossoverServiceAlignmentHelper:
          mockGennCrossoverServiceAlignmentHelper,
    );
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
