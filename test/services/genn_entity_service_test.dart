import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  const layerMutationRate = 0.25;
  const perceptronMutationRate = 0.3;
  const trackParents = false;
  const fitnessScore = 1.0;
  const updatedFitnessScore = 2.0;
  const layer = 0;
  const bias = 0.1;
  const updatedBias = 0.9;
  const threshold = 0.2;
  const weights = [0.1];
  const wave = 0;
  const gene = Gene<GENNPerceptron>(
    value: GENNPerceptron(
      layer: layer,
      bias: bias,
      threshold: threshold,
      weights: weights,
    ),
  );

  var originalDNA = const DNA<GENNPerceptron>(
    genes: [
      gene,
    ],
  );

  final randomGene = Gene(
    value: gene.value.copyWith(
      bias: updatedBias,
    ),
  );
  final randomDNA = DNA<GENNPerceptron>(
    genes: [
      randomGene,
    ],
  );

  var superCrossoverEntity = GENNEntity.fromEntity(
    entity: Entity(
      dna: originalDNA,
      fitnessScore: fitnessScore,
    ),
  );

  final updatedEntity = GENNEntity.fromEntity(
    entity: Entity(
      dna: randomDNA,
      fitnessScore: fitnessScore,
    ),
  );

  final duplicatedPerceptronLayer = GENNPerceptronLayer(
    perceptrons: [
      gene.value.copyWith(layer: gene.value.layer + 1),
    ],
  );

  final originalPerceptronLayer = GENNPerceptronLayer(
    perceptrons: [
      gene.value,
    ],
  );

  final parents = [
    Entity(dna: originalDNA, fitnessScore: fitnessScore),
    Entity(dna: originalDNA, fitnessScore: fitnessScore),
  ];

  late GENNFitnessService mockGennFitnessService;
  late NumberGenerator mockNumberGenerator;
  late PerceptronLayerMutationService mockPerceptronLayerMutationService;
  late DNAService<GENNPerceptron> mockDnaService;
  late CrossoverService<GENNPerceptron> mockCrossoverService;
  late GENNEntityService testObject;

  void mockSuperCrossover({required double nextDouble}) {
    when(() => mockGennFitnessService.calculateScore(dna: originalDNA))
        .thenAnswer((_) async => fitnessScore);
    when(() => mockCrossoverService.crossover(parents: parents, wave: wave))
        .thenAnswer((invocation) async => originalDNA.genes);
    when(() => mockNumberGenerator.nextDouble).thenReturn(nextDouble);
  }

  GENNEntityService buildTestObject({
    double? updatedLayerMutationRate,
    double? updatedPerceptronMutationRate,
    DNAService<GENNPerceptron>? updatedMockDnaService,
    GENNFitnessService? updatedMockGennFitnessService,
    GENNGeneMutationService? updatedMockGennGeneMutationService,
    bool? updatedTrackParents,
    CrossoverService<GENNPerceptron>? updatedMockCrossoverService,
    NumberGenerator? updatedMockNumberGenerator,
    PerceptronLayerMutationService? updatedMockPerceptronLayerMutationService,
  }) {
    testObject = GENNEntityService(
      layerMutationRate: updatedLayerMutationRate ?? layerMutationRate,
      perceptronMutationRate:
          updatedPerceptronMutationRate ?? perceptronMutationRate,
      dnaService: updatedMockDnaService ?? mockDnaService,
      fitnessService: updatedMockGennFitnessService ?? mockGennFitnessService,
      geneMutationService:
          updatedMockGennGeneMutationService ?? MockGENNGeneMutationService(),
      trackParents: updatedTrackParents ?? trackParents,
      crossoverService: updatedMockCrossoverService ?? mockCrossoverService,
      numberGenerator: updatedMockNumberGenerator ?? mockNumberGenerator,
      perceptronLayerMutationService:
          updatedMockPerceptronLayerMutationService ??
              mockPerceptronLayerMutationService,
    );
    return testObject;
  }

  setUp(() async {
    mockGennFitnessService = MockGENNFitnessService();
    mockNumberGenerator = MockNumberGenerator();
    mockPerceptronLayerMutationService = MockPerceptronLayerMutationService();
    mockDnaService = MockDNAService();
    mockCrossoverService = MockCrossoverService();
    testObject = buildTestObject();
  });

  group('crossOver', () {
    test(
        'does not call any mutations when randNumber is greater than layerMutationRate and perceptronMutationRate',
        () async {
      const nextDouble = 0.99;
      mockSuperCrossover(nextDouble: nextDouble);

      final actual = await testObject.crossOver(parents: parents, wave: wave);

      expect(actual, superCrossoverEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verifyNoMoreInteractions(mockNumberGenerator);
      verifyZeroInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call layer mutations when randNumber is less than layerMutationRate and greater than perceptronMutationRate',
        () async {
      testObject = buildTestObject(
        updatedLayerMutationRate: 0.5,
        updatedPerceptronMutationRate: 0.01,
      );
      const nextDouble = 0.4;
      mockSuperCrossover(nextDouble: nextDouble);

      when(() => mockNumberGenerator.nextInt(1)).thenReturn(0);

      when(
        () => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: originalPerceptronLayer,
        ),
      ).thenReturn(duplicatedPerceptronLayer);
      when(
        () => mockPerceptronLayerMutationService.addPerceptronLayer(
          entity: superCrossoverEntity,
          perceptronLayer: duplicatedPerceptronLayer,
        ),
      ).thenReturn(updatedEntity);

      final actual = await testObject.crossOver(parents: parents, wave: wave);

      expect(actual, updatedEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verify(() => mockNumberGenerator.nextInt(1));
      verify(() => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: originalPerceptronLayer));
      verify(() => mockPerceptronLayerMutationService.addPerceptronLayer(
          entity: superCrossoverEntity,
          perceptronLayer: duplicatedPerceptronLayer));
      verifyNoMoreInteractions(mockNumberGenerator);
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call layer mutations when randNumber is less than layerMutationRate and greater than perceptronMutationRate AND adds perceptron layer when numLayers is 1',
        () async {
      testObject = buildTestObject(
        updatedLayerMutationRate: 0.5,
        updatedPerceptronMutationRate: 0.01,
      );
      const nextDouble = 0.4;
      mockSuperCrossover(nextDouble: nextDouble);

      when(() => mockNumberGenerator.nextInt(1)).thenReturn(0);

      when(
        () => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: originalPerceptronLayer,
        ),
      ).thenReturn(duplicatedPerceptronLayer);
      when(
        () => mockPerceptronLayerMutationService.addPerceptronLayer(
          entity: superCrossoverEntity,
          perceptronLayer: duplicatedPerceptronLayer,
        ),
      ).thenReturn(updatedEntity);

      final actual = await testObject.crossOver(parents: parents, wave: wave);

      expect(actual, updatedEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verify(() => mockNumberGenerator.nextInt(1));
      verify(() => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: originalPerceptronLayer));
      verify(() => mockPerceptronLayerMutationService.addPerceptronLayer(
          entity: superCrossoverEntity,
          perceptronLayer: duplicatedPerceptronLayer));
      verifyNoMoreInteractions(mockNumberGenerator);
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call layer mutations when randNumber is less than layerMutationRate and greater than perceptronMutationRate AND adds perceptron layer when numLayers is 2 and nextBool is true',
        () async {
      final twoLayersOfGenes = [
        const Gene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const Gene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = DNA<GENNPerceptron>(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      testObject = buildTestObject(
        updatedLayerMutationRate: 0.5,
        updatedPerceptronMutationRate: 0.01,
      );
      const nextDouble = 0.4;
      mockSuperCrossover(nextDouble: nextDouble);
      when(() => mockNumberGenerator.nextBool).thenReturn(true);

      when(() => mockNumberGenerator.nextInt(twoLayersOfGenes.length))
          .thenReturn(layer);

      when(
        () => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: originalPerceptronLayer,
        ),
      ).thenReturn(duplicatedPerceptronLayer);
      when(
        () => mockPerceptronLayerMutationService.addPerceptronLayer(
          entity: superCrossoverEntity,
          perceptronLayer: duplicatedPerceptronLayer,
        ),
      ).thenReturn(updatedEntity);

      final actual = await testObject.crossOver(parents: parents, wave: wave);

      expect(actual, updatedEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verify(() => mockNumberGenerator.nextInt(twoLayersOfGenes.length));
      verify(() => mockNumberGenerator.nextBool);
      verifyNoMoreInteractions(mockNumberGenerator);
      verify(() => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: originalPerceptronLayer));
      verify(() => mockPerceptronLayerMutationService.addPerceptronLayer(
          entity: superCrossoverEntity,
          perceptronLayer: duplicatedPerceptronLayer));
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call layer mutations when randNumber is less than layerMutationRate and greater than perceptronMutationRate AND removes perceptron layer when numLayers is 2 and nextBool is false',
        () async {
      final twoLayersOfGenes = [
        const Gene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const Gene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = DNA<GENNPerceptron>(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      testObject = buildTestObject(
        updatedLayerMutationRate: 0.5,
        updatedPerceptronMutationRate: 0.01,
      );
      const nextDouble = 0.4;
      mockSuperCrossover(nextDouble: nextDouble);
      when(() => mockNumberGenerator.nextBool).thenReturn(false);

      when(() => mockNumberGenerator.nextInt(twoLayersOfGenes.length - 1))
          .thenReturn(layer);

      when(
        () =>
            mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
          entity: superCrossoverEntity,
          targetLayer: layer,
        ),
      ).thenAnswer((_) async => updatedEntity);

      final actual = await testObject.crossOver(parents: parents, wave: wave);

      expect(actual, updatedEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verify(() => mockNumberGenerator.nextInt(twoLayersOfGenes.length - 1));
      verify(() => mockNumberGenerator.nextBool);
      verifyNoMoreInteractions(mockNumberGenerator);
      verify(() =>
          mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
              entity: superCrossoverEntity, targetLayer: layer));
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call perceptron mutations when randNumber is greater than layerMutationRate and less than perceptronMutationRate AND adds perceptron layer when numLayers is 2 and numGenesInTargetLayer is 1 and nextBool is false',
        () async {
      final twoLayersOfGenes = [
        const Gene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const Gene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = DNA<GENNPerceptron>(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      testObject = buildTestObject(
        updatedLayerMutationRate: 0.01,
        updatedPerceptronMutationRate: 0.5,
      );
      const nextDouble = 0.4;
      mockSuperCrossover(nextDouble: nextDouble);

      when(() => mockNumberGenerator.nextInt(twoLayersOfGenes.length - 1))
          .thenReturn(layer);

      when(
        () => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: superCrossoverEntity,
          targetLayer: layer,
        ),
      ).thenAnswer((_) async => updatedEntity);

      final actual = await testObject.crossOver(parents: parents, wave: wave);

      expect(actual, updatedEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verify(() => mockNumberGenerator.nextInt(twoLayersOfGenes.length - 1));
      verifyNoMoreInteractions(mockNumberGenerator);
      verify(() => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: superCrossoverEntity, targetLayer: layer));
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call perceptron mutations when randNumber is greater than layerMutationRate and less than perceptronMutationRate AND adds perceptron layer when numLayers is 2 and numGenesInTargetLayer is 2 and nextBool is true',
        () async {
      final twoLayersOfGenes = [
        const Gene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const Gene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const Gene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = DNA<GENNPerceptron>(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      testObject = buildTestObject(
        updatedLayerMutationRate: 0.01,
        updatedPerceptronMutationRate: 0.5,
      );
      const nextDouble = 0.4;
      mockSuperCrossover(nextDouble: nextDouble);

      when(() => mockNumberGenerator.nextInt(1)).thenReturn(layer);
      when(() => mockNumberGenerator.nextBool).thenReturn(true);

      when(
        () => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: superCrossoverEntity,
          targetLayer: layer,
        ),
      ).thenAnswer((_) async => updatedEntity);

      final actual = await testObject.crossOver(parents: parents, wave: wave);

      expect(actual, updatedEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verify(() => mockNumberGenerator.nextInt(1));
      verify(() => mockNumberGenerator.nextBool);
      verifyNoMoreInteractions(mockNumberGenerator);
      verify(() => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: superCrossoverEntity, targetLayer: layer));
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call perceptron mutations when randNumber is greater than layerMutationRate and less than perceptronMutationRate AND removes perceptron layer when numLayers is 2 and numGenesInTargetLayer is 2 and nextBool is false',
        () async {
      final twoLayersOfGenes = [
        const Gene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const Gene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const Gene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = DNA<GENNPerceptron>(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      testObject = buildTestObject(
        updatedLayerMutationRate: 0.01,
        updatedPerceptronMutationRate: 0.5,
      );
      const nextDouble = 0.4;
      mockSuperCrossover(nextDouble: nextDouble);

      when(() => mockNumberGenerator.nextInt(1)).thenReturn(layer);
      when(() => mockNumberGenerator.nextBool).thenReturn(false);

      when(
        () => mockPerceptronLayerMutationService.removePerceptronFromLayer(
          entity: superCrossoverEntity,
          targetLayer: layer,
        ),
      ).thenAnswer((_) async => updatedEntity);

      final actual = await testObject.crossOver(parents: parents, wave: wave);

      expect(actual, updatedEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verify(() => mockNumberGenerator.nextInt(1));
      verify(() => mockNumberGenerator.nextBool);
      verifyNoMoreInteractions(mockNumberGenerator);
      verify(() => mockPerceptronLayerMutationService.removePerceptronFromLayer(
          entity: superCrossoverEntity, targetLayer: layer));
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call layer mutations when randNumber is less than layerMutationRate and calls perceptron mutations when randNumber is less than perceptronMutationRate',
        () async {
      final twoLayersOfGenes = [
        const Gene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const Gene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const Gene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];

      final updatedUpdatedEntity = updatedEntity.copyWith(
        fitnessScore: updatedFitnessScore,
      );

      // Update the originalDNA that every test uses
      originalDNA = DNA<GENNPerceptron>(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      final superCrossoverGENNNeuralNetwork =
          GENNNeuralNetwork.fromGenes(genes: superCrossoverEntity.dna.genes);

      testObject = buildTestObject(
        updatedLayerMutationRate: 0.5,
        updatedPerceptronMutationRate: 0.5,
      );
      const nextDouble = 0.4;
      mockSuperCrossover(nextDouble: nextDouble);

      when(() => mockNumberGenerator.nextInt(2)).thenReturn(layer);
      when(() => mockNumberGenerator.nextBool).thenReturn(true);

      when(() => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: superCrossoverGENNNeuralNetwork
              .layers[layer])).thenReturn(duplicatedPerceptronLayer);

      when(() => mockPerceptronLayerMutationService.addPerceptronLayer(
              entity: superCrossoverEntity,
              perceptronLayer: duplicatedPerceptronLayer))
          .thenReturn(updatedEntity);

      when(
        () => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: updatedEntity,
          targetLayer: layer,
        ),
      ).thenAnswer((_) async => updatedUpdatedEntity);

      final actual = await testObject.crossOver(parents: parents, wave: wave);

      expect(actual, updatedUpdatedEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verify(() => mockNumberGenerator.nextInt(2));
      verify(() => mockNumberGenerator.nextBool);
      verifyNoMoreInteractions(mockNumberGenerator);
      verify(() => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: updatedEntity, targetLayer: layer));
      verify(() => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
          gennPerceptronLayer: superCrossoverGENNNeuralNetwork.layers[layer]));
      verify(() => mockPerceptronLayerMutationService.addPerceptronLayer(
          entity: superCrossoverEntity,
          perceptronLayer: duplicatedPerceptronLayer));
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });
  });
}
