part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

/// Converts [GENNPerceptron] objects to and from JSON.
class GeneJsonConverter
    extends JsonConverter<GENNPerceptron, Map<String, dynamic>> {
  @override
  fromJson(json) {
    return GENNPerceptron.fromJson(json);
  }

  @override
  toJson(GENNPerceptron object) {
    return object.toJson();
  }
}
