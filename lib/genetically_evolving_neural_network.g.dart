// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'genetically_evolving_neural_network.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GENNDNA _$GENNDNAFromJson(Map<String, dynamic> json) => GENNDNA(
      genes: (json['genes'] as List<dynamic>)
          .map((e) => GENNGene.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GENNDNAToJson(GENNDNA instance) => <String, dynamic>{
      'genes': instance.genes,
    };

GENNEntity _$GENNEntityFromJson(Map<String, dynamic> json) => GENNEntity(
      dna: GENNDNA.fromJson(json['dna'] as Map<String, dynamic>),
      fitnessScore: (json['fitnessScore'] as num).toDouble(),
      parents: (json['parents'] as List<dynamic>?)
          ?.map((e) => GENNEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GENNEntityToJson(GENNEntity instance) =>
    <String, dynamic>{
      'fitnessScore': instance.fitnessScore,
      'parents': instance.parents,
      'dna': instance.dna,
    };

GENNGene _$GENNGeneFromJson(Map<String, dynamic> json) => GENNGene(
      value: GENNPerceptron.fromJson(json['value'] as Map<String, dynamic>),
      mutatedWaves: (json['mutatedWaves'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
    );

Map<String, dynamic> _$GENNGeneToJson(GENNGene instance) => <String, dynamic>{
      'value': instance.value,
      'mutatedWaves': instance.mutatedWaves,
    };

GENNGeneration _$GENNGenerationFromJson(Map<String, dynamic> json) =>
    GENNGeneration(
      wave: json['wave'] as int,
      population:
          GENNPopulation.fromJson(json['population'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$GENNGenerationToJson(GENNGeneration instance) =>
    <String, dynamic>{
      'wave': instance.wave,
      'population': instance.population,
    };

GENNNeuralNetwork _$GENNNeuralNetworkFromJson(Map<String, dynamic> json) =>
    GENNNeuralNetwork(
      layers: (json['layers'] as List<dynamic>)
          .map((e) => GENNPerceptronLayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      guessService: NeuralNetwork._guessServiceFromJson(json['guessService']),
    );

Map<String, dynamic> _$GENNNeuralNetworkToJson(GENNNeuralNetwork instance) =>
    <String, dynamic>{
      'guessService': NeuralNetwork._guessServiceToJson(instance.guessService),
      'layers': instance.layers,
    };

GENNPerceptron _$GENNPerceptronFromJson(Map<String, dynamic> json) =>
    GENNPerceptron(
      layer: json['layer'] as int,
      bias: (json['bias'] as num).toDouble(),
      threshold: (json['threshold'] as num).toDouble(),
      weights: (json['weights'] as List<dynamic>)
          .map((e) => (e as num).toDouble())
          .toList(),
    );

Map<String, dynamic> _$GENNPerceptronToJson(GENNPerceptron instance) =>
    <String, dynamic>{
      'bias': instance.bias,
      'threshold': instance.threshold,
      'weights': instance.weights,
      'layer': instance.layer,
    };

GENNPerceptronLayer _$GENNPerceptronLayerFromJson(Map<String, dynamic> json) =>
    GENNPerceptronLayer(
      perceptrons: (json['perceptrons'] as List<dynamic>)
          .map((e) => GENNPerceptron.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$GENNPerceptronLayerToJson(
        GENNPerceptronLayer instance) =>
    <String, dynamic>{
      'perceptrons': instance.perceptrons,
    };

GENNPopulation _$GENNPopulationFromJson(Map<String, dynamic> json) =>
    GENNPopulation(
      entities: (json['entities'] as List<dynamic>)
          .map((e) => GENNEntity.fromJson(e as Map<String, dynamic>))
          .toList(),
      sortingMethod: json['sortingMethod'] == null
          ? _fallbackSortMethod
          : Population._sortingMethodFromJson(json['sortingMethod']),
    );

Map<String, dynamic> _$GENNPopulationToJson(GENNPopulation instance) =>
    <String, dynamic>{
      'sortingMethod': Population._sortingMethodToJson(instance.sortingMethod),
      'entities': instance.entities,
    };
