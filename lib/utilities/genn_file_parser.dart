part of 'package:genetically_evolving_neural_network/genetically_evolving_neural_network.dart';

// TODO: Documentation on all the utilities folder files
class GENNFileParser extends FileParser<GENNPerceptron> {
  GENNFileParser({
    GeneJsonConverter? geneJsonConverter,
    GENNGenerationJsonConverter? generationJsonConverter,
    super.getDirectoryPath,
  }) : super(
          geneJsonConverter: geneJsonConverter ?? GeneJsonConverter(),
          generationJsonConverter:
              generationJsonConverter ?? GENNGenerationJsonConverter(),
        );

  @override
  String generationFileName(int wave) => 'genn wave $wave.txt';
}
