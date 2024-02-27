# genetically_evolving_neural_network
 This package mimicks the process of Genetic Evolution on Entities, each comprised of a Neural Network, through cross-breeding parents and genetic mutations.


![zoomed_in_GENN](https://github.com/dancout/genetically_evolving_neural_network/assets/5490028/178ff29c-029d-4bfb-bf9a-12a816ed023b)



## Table of Contents
- [Usage](#usage)
  - [How it works](#how-it-works)
  - [To Begin](#to-begin)
  - [File Parsing](#file-parsing)
- [More Complex Examples](#more-complex-examples)

## Usage
You simply need to define your own `FitnessService` to determine how well an Entity's decisions perform, along with a config that states how often the DNA of your population should mutate.

### How it works
This library will generate a randomized initial population of Neural Network Entities. You can think of an Entity's DNA as being a Neural Network, and the genes within that DNA being perceptrons within the Neural Network.

Each Neural Network is evaluated against a `FitnessService` and assigned a fitness score based on how well it performs a task.

Entities with a higher fitness score have a higher probability of being chosen as a parent to reproduce and create offspring for the next generation.

Genes from each parent are taken to create the child's new DNA, and there is a chance that those genes will mutate (just like how reproduction and evolution happen in real life).

This cycle repeats itself, keeping the high performing Neural Networks within the gene pool and allowing for the process of evolution through mutations.

### To Begin:
* Define your own `FitnessService` that assigns a fitness score to an entity based on how well it performs. This could mean guessing if a number is positive or negative, choosing a next move in a chess game, or any other decision a neural network can make.
* Define your `GeneticEvolutionConfig`, responsible for how many entities should exist within a population, how often an Entity's DNA should mutate, and other adjustable values.

## Positive or Negative Number Classifier Example
#### In this example, we will guess whether an input is positive or negative.
(You can view the entire file [here](https://pub.dev/packages/genetically_evolving_neural_network/example#full-working-example))


First, define the `GENNFitnessService` that rewards correctly identifying if a number is positive or negative.
```dart
/// The inputs for this Neural Network, from -1 to 1 in increments of 0.1.
List<double> get inputs => List.generate(10, (index) => index * 0.1)
  ..addAll(List.generate(9, (index) => (index + 1) * -0.1));

/// The scoring function that will be used to evolve entities of a population
class PositiveNumberFitnessService extends GENNFitnessService {
  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Calculate how many correct guesses were made
    return inputs.fold(0, (previousValue, input) {
      final guess = neuralNetwork.guess(inputs: [input])[0];
      // Only add a point if the neural network guesses correctly
      if ((input > 0 && guess > 0) || (input <= 0 && guess == 0)) {
        return previousValue + 1;
      }
      return previousValue;
    }).toDouble();
  }
}
```

Next, you initialize a `GeneticEvolution` object, responsible for creating populations of child Entities.
```dart
final config = GENNGeneticEvolutionConfig(
  numInitialInputs: 1, // 1 input into neural network
  numOutputs: 1, // 1 output from neural network
  layerMutationRate: 0.1, // 10% chance to add/remove layer to network
  perceptronMutationRate: 0.2, // 20% chance to add/remove perceptron to layer
  mutationRate: 0.05, // 5% chance to mutate an existing perceptron
);
```

Next, you can use the fitness service and config to create a `GENN` object.
```dart
final genn = GENN.create(
  config: config,
  fitnessService: PositiveNumberFitnessService(),
);
```

And finally, you can access the next generation of Entities using `nextGeneration()`.
```dart
final nextGen = await genn.nextGeneration();
```

### File Parsing
You can write specific generations to a file, and similarly read in specific generations stored on a file.

In order to write the current `GENNGeneration` object to a file
```dart
genn.writeGenerationToFile();
```

In order to load in a specific `GENNGeneration` read from a file
```dart
genn.loadGenerationFromFile(wave: 10);
```

## More Complex Examples
Guessing if a number is positive or negative is not a particularly impressive use case for a Neural Network, but it is very simple to understand and helps grasp the concept. If you'd like to see a more complex problem, check out these [examples](https://pub.dev/packages/genetically_evolving_neural_network/example).


