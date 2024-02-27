part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Converts [GENNGeneration] objects to and from JSON.
class GENNGenerationJsonConverter
    extends GenerationJsonConverter<GENNPerceptron> {
  @override
  GENNGeneration fromJson(Map<String, dynamic> json) {
    return GENNGeneration.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Generation<GENNPerceptron> object) {
    return object.toJson();
  }
}
