part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GENNGeneticEvolutionConfig extends GeneticEvolutionConfig {
  GENNGeneticEvolutionConfig({
    required this.numInitialInputs,
    required int numOutputs,
    required this.layerMutationRate,
    required this.perceptronMutationRate,

    /// The rate at which individual Perceptrons will mutate during crossover.
    required super.mutationRate,
    super.canReproduceWithSelf,
    super.numParents,
    super.populationSize,
    super.random,
    super.trackMutatedWaves,
    super.trackParents,
    super.generationsToTrack,
  }) : super(numGenes: numOutputs);

  /// Represents the number of initial inputs for creating a Random Gene.
  final int numInitialInputs;

  /// The rate at which a PerceptronLayer will be added or removed from an
  /// Entity.
  final double layerMutationRate;

  /// The rate at which a Perceptron will be added or removed from a given
  /// PerceptronLayer.
  final double perceptronMutationRate;

  // TODO: Verify this function. We used copilot for it!
  GENNGeneticEvolutionConfig copyWith({
    int? numInitialInputs,
    int? numOutputs,
    double? layerMutationRate,
    double? perceptronMutationRate,
    double? mutationRate,
    bool? canReproduceWithSelf,
    int? numParents,
    int? populationSize,
    bool? trackMutatedWaves,
    bool? trackParents,
    int? generationsToTrack,
    Random? random,
  }) {
    return GENNGeneticEvolutionConfig(
      numInitialInputs: numInitialInputs ?? this.numInitialInputs,
      numOutputs: numOutputs ?? this.numGenes,
      layerMutationRate: layerMutationRate ?? this.layerMutationRate,
      perceptronMutationRate:
          perceptronMutationRate ?? this.perceptronMutationRate,
      mutationRate: mutationRate ?? this.mutationRate,
      canReproduceWithSelf: canReproduceWithSelf ?? super.canReproduceWithSelf,
      numParents: numParents ?? super.numParents,
      populationSize: populationSize ?? super.populationSize,
      trackMutatedWaves: trackMutatedWaves ?? super.trackMutatedWaves,
      trackParents: trackParents ?? super.trackParents,
      generationsToTrack: generationsToTrack ?? super.generationsToTrack,
      random: random ?? super.random,
    );
  }

  factory GENNGeneticEvolutionConfig.fromJson(Map<String, dynamic> json) {
    return GENNGeneticEvolutionConfig(
      numInitialInputs: json['numInitialInputs'] as int,
      numOutputs: json['numOutputs'] as int,
      layerMutationRate: json['layerMutationRate'] as double,
      perceptronMutationRate: json['perceptronMutationRate'] as double,
      mutationRate: json['mutationRate'] as double,
      canReproduceWithSelf: json['canReproduceWithSelf'] as bool?,
      generationsToTrack: json['generationsToTrack'] as int?,
      numParents: json['numParents'] as int?,
      populationSize: json['populationSize'] as int?,
      trackMutatedWaves: json['trackMutatedWaves'] as bool?,
      trackParents: json['trackParents'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: Would it be better to place the super.toJson in here?
    return {
      'numInitialInputs': numInitialInputs,
      // TODO: Note that numGenes is different than numOutputs!!!!!
      'numOutputs': numGenes,
      'layerMutationRate': layerMutationRate,
      'perceptronMutationRate': perceptronMutationRate,
      'mutationRate': mutationRate,
      'canReproduceWithSelf': canReproduceWithSelf,
      'generationsToTrack': generationsToTrack,
      'numParents': numParents,
      'populationSize': populationSize,
      'trackMutatedWaves': trackMutatedWaves,
      'trackParents': trackParents,
    };
  }
}
