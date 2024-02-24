part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

class GenerationJsonConverter
    extends JsonConverter<GENNGeneration, Map<String, dynamic>> {
  @override
  GENNGeneration fromJson(Map<String, dynamic> json) {
    return GENNGeneration.fromJson(json);
  }

  @override
  // Map<String, dynamic> toJson(dynamic object) {
  // Map<String, dynamic> toJson(GENNGeneration object) {
  Map<String, dynamic> toJson(Generation<GENNPerceptron> object) {
    return object.toJson();
  }
}
