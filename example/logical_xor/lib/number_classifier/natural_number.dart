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

  List<double> get asCorrectGuess {
    return List.generate(NaturalNumber.values.length, (index) {
      if (this == NaturalNumber.values[index]) {
        // Return a 1, implying that we have 100% confidence that this is the
        // correct guess.
        return 1;
      }

      // Return a 0, implying that we have a 0% confidence that this is the
      //correct guess.
      return 0;
    });
  }

  static const numPixels = 15;

  List<double> asPixels() {
    late List<double> val;

    switch (this) {
      case NaturalNumber.zero:
        val = [1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.one:
        val = [0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1];
        break;
      case NaturalNumber.two:
        val = [1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1];
        break;
      case NaturalNumber.three:
        val = [1, 1, 1, 0, 0, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.four:
        val = [1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1];
        break;
      case NaturalNumber.five:
        val = [1, 1, 1, 1, 0, 0, 1, 1, 1, 0, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.six:
        val = [1, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.seven:
        val = [1, 1, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1, 0, 0, 1];
        break;
      case NaturalNumber.eight:
        val = [1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1];
        break;
      case NaturalNumber.nine:
        val = [1, 1, 1, 1, 0, 1, 1, 1, 1, 0, 0, 1, 0, 0, 1];
        break;
    }

    assert(
      val.length == numPixels,
      'The NaturalNumber asPixels must be 15 characters',
    );
    return val;
  }
}
