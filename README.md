# genetically_evolving_neural_network
 This package implements a Genetically Evolving Neural Network. A Population of Entities, each containing a mutable Neural Network to drive decisions, will reproduce to create a new Generation (through cross-breeding the DNA of high-performing Entities and introducing new mutations).

![zoomed_in_GENN](https://github.com/dancout/genetically_evolving_neural_network/assets/5490028/178ff29c-029d-4bfb-bf9a-12a816ed023b)


## Usage
You simply need to define your own `FitnessService` to determine how well an Entity's decisions perform, along with a config that states how often the DNA of your population should mutate.

### How it works
This library will generate a randomized initial population of Neural Network Entities. You can think of an Entity's DNA as being a Neural Network, and the genes within that DNA being perceptrons within the Neural Network.

Each Neural Network is evaluated against a `FitnessService` and assigned a fitness score based on how well it performs a task.

Entities with a higher fitness score have a higher probability of being chosen as a parent to reproduce and create offspring for the next generation.

Genes from each parent are taken to create the child's new DNA, and there is a chance that those genes will mutate (just like how reproduction and evolution happen in real life).

This cycle repeats itself, keeping the high performing Neural Networks within the gene pool and allowing for the process of evolution through mutations.

### To begin, you'll need to:
* Define your own `FitnessService` that assigns a fitness score to an entity based on how well it performs. This could mean guessing if a number is positive or negative, choosing a next move in a chess game, or any other decision a neural network can make.
* Define your `GeneticEvolutionConfig`, responsible for how many entities should exist within a population, how often an Entity's DNA should mutate, and other adjustable values.

## Positive Number Example
#### In this example, we will guess whether an input is positive or negative.

First, define the `GENNFitnessService` that rewards correctly identifying if a number is positive or negative.
```dart
class PositiveNumberFitnessService extends GENNFitnessService {
  @override
  Future<double> gennScoringFunction({
    required GENNNeuralNetwork neuralNetwork,
  }) async {
    // Calculate guesses based on both positive and negative inputs.
    final positiveGuess = neuralNetwork.guess(inputs: [0.5]);
    final negativeGuess = neuralNetwork.guess(inputs: [-0.5]);

    // A guess of 0 means negative, and anything else means positive.
    final positiveGuessScore = positiveGuess[0] > 0 ? 1.0 : 0.0;
    final negativeGuessScore = negativeGuess[0] == 0 ? 1.0 : 0.0;

    // Add the guess scores together, rewarding only correct answers.
    return positiveGuessScore + negativeGuessScore;
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

## More Complex Examples
Guessing if a number is positive or negative is not a particularly impressive use case for a Neural Network, but it is very simple to understand and helps grasp the concept. If you'd like to see a more complex problem, check out these [examples](https://pub.dev/packages/genetically_evolving_neural_network/example).
