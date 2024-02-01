import 'package:flutter_test/flutter_test.dart';
import 'package:genetic_evolution/genetic_evolution.dart';
import 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  const layerMutationRate = 0.5;
  const perceptronMutationRate = 0.5;
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

  late GENNDNA originalDNA;

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

  late GENNEntity superCrossoverEntity;

  final updatedEntity = GENNEntity.fromEntity(
    entity: Entity(
      dna: randomDNA,
      fitnessScore: updatedFitnessScore,
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

  late NumberGenerator mockNumberGenerator;
  late PerceptronLayerMutationService mockPerceptronLayerMutationService;
  late GENNEntityServiceHelper testObject;

  setUp(() async {
    final genes = [
      gene,
    ];
    originalDNA = GENNDNA(
      genes: genes,
    );
    superCrossoverEntity = GENNEntity.fromEntity(
      entity: Entity(
        dna: originalDNA,
        fitnessScore: fitnessScore,
      ),
    );

    mockNumberGenerator = MockNumberGenerator();
    mockPerceptronLayerMutationService = MockPerceptronLayerMutationService();
    testObject = GENNEntityServiceHelper(
      numberGenerator: mockNumberGenerator,
      layerMutationRate: layerMutationRate,
      perceptronMutationRate: perceptronMutationRate,
      perceptronLayerMutationService: mockPerceptronLayerMutationService,
    );
  });

  group('mutatePerceptronLayersWithinEntity', () {
    test(
        'does nothing when random number is greater than or equal to layerMutationRate',
        () async {
      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(layerMutationRate + 0.1);

      final actual = await testObject.mutatePerceptronLayersWithinEntity(
        child: superCrossoverEntity,
      );

      expect(actual, superCrossoverEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verifyNoMoreInteractions(mockNumberGenerator);
      verifyZeroInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does add PerceptronLayer when random number is less than layerMutationRate and numLayers is 1 and nextBool is false',
        () async {
      when(() => mockNumberGenerator.nextBool).thenReturn(false);
      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(layerMutationRate - 0.1);
      const targetLayer = 0;
      when(() =>
              mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum + 1))
          .thenReturn(targetLayer);
      when(() => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
            gennPerceptronLayer: originalPerceptronLayer,
          )).thenReturn(duplicatedPerceptronLayer);
      when(() => mockPerceptronLayerMutationService.addPerceptronLayerToEntity(
              entity: superCrossoverEntity,
              perceptronLayer: duplicatedPerceptronLayer))
          .thenAnswer((_) async => updatedEntity);

      final actual = await testObject.mutatePerceptronLayersWithinEntity(
        child: superCrossoverEntity,
      );

      expect(actual, updatedEntity);

      verifyInOrder([
        () => mockNumberGenerator.nextDouble,
        () => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum + 1),
        () => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
              gennPerceptronLayer: originalPerceptronLayer,
            ),
        () => mockPerceptronLayerMutationService.addPerceptronLayerToEntity(
              entity: superCrossoverEntity,
              perceptronLayer: duplicatedPerceptronLayer,
            ),
      ]);
      verifyNoMoreInteractions(mockNumberGenerator);
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does add PerceptronLayer when random number is less than layerMutationRate and numLayers is 2 and nextBool is true',
        () async {
      final twoLayersOfGenes = [
        const GENNGene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const GENNGene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = GENNDNA(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      when(() => mockNumberGenerator.nextBool).thenReturn(true);
      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(layerMutationRate - 0.1);
      const targetLayer = 0;
      when(() =>
              mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum + 1))
          .thenReturn(targetLayer);
      when(() => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
            gennPerceptronLayer: originalPerceptronLayer,
          )).thenReturn(duplicatedPerceptronLayer);
      when(() => mockPerceptronLayerMutationService.addPerceptronLayerToEntity(
              entity: superCrossoverEntity,
              perceptronLayer: duplicatedPerceptronLayer))
          .thenAnswer((_) async => updatedEntity);

      final actual = await testObject.mutatePerceptronLayersWithinEntity(
        child: superCrossoverEntity,
      );

      expect(actual, updatedEntity);

      verifyInOrder([
        () => mockNumberGenerator.nextDouble,
        () => mockNumberGenerator.nextBool,
        () => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum + 1),
        () => mockPerceptronLayerMutationService.duplicatePerceptronLayer(
              gennPerceptronLayer: originalPerceptronLayer,
            ),
        () => mockPerceptronLayerMutationService.addPerceptronLayerToEntity(
              entity: superCrossoverEntity,
              perceptronLayer: duplicatedPerceptronLayer,
            ),
      ]);
      verifyNoMoreInteractions(mockNumberGenerator);
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does remove PerceptronLayer when random number is less than layerMutationRate and numLayers is 2 and nextBool is false',
        () async {
      final twoLayersOfGenes = [
        const GENNGene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const GENNGene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = GENNDNA(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      when(() => mockNumberGenerator.nextBool).thenReturn(false);
      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(layerMutationRate - 0.1);
      const targetLayer = 0;
      when(() => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum))
          .thenReturn(targetLayer);
      when(() =>
          mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
            entity: superCrossoverEntity,
            targetLayer: targetLayer,
          )).thenAnswer((_) async => updatedEntity);

      final actual = await testObject.mutatePerceptronLayersWithinEntity(
        child: superCrossoverEntity,
      );

      expect(actual, updatedEntity);

      verifyInOrder([
        () => mockNumberGenerator.nextDouble,
        () => mockNumberGenerator.nextBool,
        () => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum),
        () =>
            mockPerceptronLayerMutationService.removePerceptronLayerFromEntity(
              entity: superCrossoverEntity,
              targetLayer: targetLayer,
            ),
      ]);
      verifyNoMoreInteractions(mockNumberGenerator);
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });
  });

  group('mutatePerceptronsWithinLayer', () {
    test(
        'does nothing when random number is greater than or equal to perceptronMutationRate',
        () async {
      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(perceptronMutationRate + 0.1);

      final actual = await testObject.mutatePerceptronsWithinLayer(
        child: superCrossoverEntity,
      );

      expect(actual, superCrossoverEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verifyNoMoreInteractions(mockNumberGenerator);
      verifyZeroInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does nothing when random number is less than perceptronMutationRate and there is only 1 PerceptronLayer',
        () async {
      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(perceptronMutationRate - 0.1);

      final actual = await testObject.mutatePerceptronsWithinLayer(
        child: superCrossoverEntity,
      );

      expect(actual, superCrossoverEntity);

      verify(() => mockNumberGenerator.nextDouble);
      verifyNoMoreInteractions(mockNumberGenerator);
      verifyZeroInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call to add a Perceptron to a PerceptronLayer when random number is less than perceptronMutationRate and there is more than 1 PerceptronLayer and only 1 Perceptron in the chosen PerceptronLayer',
        () async {
      final twoLayersOfGenes = [
        const GENNGene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const GENNGene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = GENNDNA(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      const targetLayer = 0;
      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(perceptronMutationRate - 0.1);
      when(
        () => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum),
      ).thenReturn(targetLayer);
      when(() => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: superCrossoverEntity,
          targetLayer: targetLayer)).thenAnswer((_) async => updatedEntity);

      final actual = await testObject.mutatePerceptronsWithinLayer(
        child: superCrossoverEntity,
      );

      expect(actual, updatedEntity);

      verifyInOrder([
        () => mockNumberGenerator.nextDouble,
        () => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum),
        () => mockPerceptronLayerMutationService.addPerceptronToLayer(
            entity: superCrossoverEntity, targetLayer: targetLayer),
      ]);

      verifyNoMoreInteractions(mockNumberGenerator);
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call to add a Perceptron to a PerceptronLayer when random number is less than perceptronMutationRate and there is more than 1 PerceptronLayer and more than 1 Perceptron in the chosen PerceptronLayer and nextBool is true',
        () async {
      final twoLayersOfGenes = [
        const GENNGene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const GENNGene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const GENNGene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = GENNDNA(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      const targetLayer = 0;
      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(perceptronMutationRate - 0.1);
      when(
        () => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum),
      ).thenReturn(targetLayer);
      when(() => mockNumberGenerator.nextBool).thenReturn(true);
      when(() => mockPerceptronLayerMutationService.addPerceptronToLayer(
          entity: superCrossoverEntity,
          targetLayer: targetLayer)).thenAnswer((_) async => updatedEntity);

      final actual = await testObject.mutatePerceptronsWithinLayer(
        child: superCrossoverEntity,
      );

      expect(actual, updatedEntity);

      verifyInOrder([
        () => mockNumberGenerator.nextDouble,
        () => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum),
        () => mockNumberGenerator.nextBool,
        () => mockPerceptronLayerMutationService.addPerceptronToLayer(
            entity: superCrossoverEntity, targetLayer: targetLayer),
      ]);

      verifyNoMoreInteractions(mockNumberGenerator);
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });

    test(
        'does call to remove a Perceptron from a PerceptronLayer when random number is less than perceptronMutationRate and there is more than 1 PerceptronLayer and more than 1 Perceptron in the chosen PerceptronLayer and nextBool is false',
        () async {
      final twoLayersOfGenes = [
        const GENNGene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const GENNGene(
          value: GENNPerceptron(
            layer: layer,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
        const GENNGene(
          value: GENNPerceptron(
            layer: layer + 1,
            bias: bias,
            threshold: threshold,
            weights: weights,
          ),
        ),
      ];
      // Update the originalDNA that every test uses
      originalDNA = GENNDNA(
        genes: twoLayersOfGenes,
      );

      superCrossoverEntity = GENNEntity.fromEntity(
        entity: Entity(
          dna: originalDNA,
          fitnessScore: fitnessScore,
        ),
      );

      const targetLayer = 0;
      when(() => mockNumberGenerator.nextDouble)
          .thenReturn(perceptronMutationRate - 0.1);
      when(
        () => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum),
      ).thenReturn(targetLayer);
      when(() => mockNumberGenerator.nextBool).thenReturn(false);
      when(() => mockPerceptronLayerMutationService.removePerceptronFromLayer(
            entity: superCrossoverEntity,
            targetLayer: targetLayer,
          )).thenAnswer((_) async => updatedEntity);

      final actual = await testObject.mutatePerceptronsWithinLayer(
        child: superCrossoverEntity,
      );

      expect(actual, updatedEntity);

      verifyInOrder([
        () => mockNumberGenerator.nextDouble,
        () => mockNumberGenerator.nextInt(superCrossoverEntity.maxLayerNum),
        () => mockNumberGenerator.nextBool,
        () => mockPerceptronLayerMutationService.removePerceptronFromLayer(
            entity: superCrossoverEntity, targetLayer: targetLayer),
      ]);

      verifyNoMoreInteractions(mockNumberGenerator);
      verifyNoMoreInteractions(mockPerceptronLayerMutationService);
    });
  });
}
