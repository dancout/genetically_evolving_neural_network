part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

// TODO: Documentation on all the utilities folder files
class GENNFileParser extends FileParser<GENNGeneration> {
  GENNFileParser({
    required super.geneJsonConverter,
    required super.generationJsonConverter,
    super.getDirectoryPath,
  });

  @override
  String generationFileName(int wave) => 'genn wave $wave.txt';
}
