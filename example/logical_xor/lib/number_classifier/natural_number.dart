/// Represents the natural numbers from 0 to 9, inclusively.
enum NaturalNumber {
  zero,
  one,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
}

extension NaturalNumberExtension on NaturalNumber {
  static NaturalNumber parse({required int number}) {
    for (int i = 0; i < NaturalNumber.values.length; i++) {
      if (i == number) {
        return NaturalNumber.values[i];
      }
    }
    // Theoretically, we should never see this exception.
    throw Exception(
        'number: $number is out the 0-${NaturalNumber.values.length - 1} (inclusive) range');
  }

  static const numPixels = 15;

  PixelImage asPixelImage() {
    late List<double> pixels;

    switch (this) {
      case NaturalNumber.zero:
        pixels = [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.one:
        pixels = [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1];
        break;
      case NaturalNumber.two:
        pixels = [1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1];
        break;
      case NaturalNumber.three:
        pixels = [1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.four:
        pixels = [1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1];
        break;
      case NaturalNumber.five:
        pixels = [1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.six:
        pixels = [1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.seven:
        pixels = [1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1];
        break;
      case NaturalNumber.eight:
        pixels = [1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.nine:
        pixels = [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1];
        break;
    }

    assert(
      pixels.length == numPixels,
      'The NaturalNumber asPixels must be 15 characters',
    );
    return PixelImage(pixels: pixels);
  }
}

/// Represents an Image as a list of pixels.
class PixelImage {
  /// Represents an Image as a list of pixels.
  const PixelImage({
    required this.pixels,
  });
  final List<double> pixels;
}
