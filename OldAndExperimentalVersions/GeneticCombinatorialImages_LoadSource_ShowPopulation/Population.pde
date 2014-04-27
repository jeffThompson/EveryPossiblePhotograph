
class Population {

  float mutationRate;           // mutation rate
  DNA[] population;             // array to hold the current population
  ArrayList<DNA> matingPool;    // arrayList which we will use for our "mating pool"
  String target;                // target phrase
  int generations;              // number of generations
  boolean finished;             // are we finished evolving?
  double perfectScore;          // formerly an int, we need the double's size for longer strings

  Population(String p, float m, int num) {
    target = p;
    mutationRate = m;
    population = new DNA[num];
    for (int i = 0; i < population.length; i++) {
      population[i] = new DNA(target.length());
    }
    calcFitness();
    matingPool = new ArrayList<DNA>();
    finished = false;
    generations = 0;

    // perfectScore = target.length();            // handles longer texts but takes WAAAYY longer
    // perfectScore = 1.0;                        // from the original example (slower)
    perfectScore = pow(2, target.length());       // no longer cast to int since we're using doubles
  }

  // Fill our fitness array with a value for every member of the population
  void calcFitness() {
    for (int i = 0; i < population.length; i++) {
      population[i].fitness(target);
    }
  }

  // Generate a mating pool
  void naturalSelection() {
    // Clear the ArrayList
    matingPool.clear();

    float maxFitness = 0;
    for (int i = 0; i < population.length; i++) {
      if (population[i].fitness > maxFitness) {
        maxFitness = (float)population[i].fitness;
      }
    }

    // Based on fitness, each member will get added to the mating pool a certain number of times
    // a higher fitness = more entries to mating pool = more likely to be picked as a parent
    // a lower fitness = fewer entries to mating pool = less likely to be picked as a parent
    for (int i = 0; i < population.length; i++) {

      float fitness = map((float)population[i].fitness, 0, maxFitness, 0, 1);
      int n = int(fitness * 100); // Arbitrary multiplier, we can also use monte carlo method
      for (int j = 0; j < n; j++) { // and pick two random numbers
        matingPool.add(population[i]);
      }
    }
  }

  // Create a new generation
  void generate() {
    // Refill the population with children from the mating pool
    for (int i = 0; i < population.length; i++) {
      int a = int(random(matingPool.size()));
      int b = int(random(matingPool.size()));
      DNA partnerA = matingPool.get(a);
      DNA partnerB = matingPool.get(b);
      DNA child = partnerA.crossover(partnerB);
      child.mutate(mutationRate);
      population[i] = child;
    }
    generations++;
  }


  // Compute the current "most fit" member of the population
  String getBest() {
    double worldrecord = 0.0;    // also formerly an int
    int index = 0;
    for (int i = 0; i < population.length; i++) {
      if (population[i].fitness > worldrecord) {
        index = i;
        worldrecord = population[i].fitness;
      }
    }

    if (worldrecord == perfectScore) {
      finished = true;
    }
    return population[index].getPhrase();
  }

  boolean finished() {
    return finished;
  }

  int getGenerations() {
    return generations;
  }

  // Compute average fitness for the population
  float getAverageFitness() {
    float total = 0;
    for (int i = 0; i < population.length; i++) {
      total += population[i].fitness;
    }
    return total / (population.length);
  }

  // modified to return an array of the entire population
  String[] allPhrases() {
    String[] s = new String[0];
    for (int i = 0; i < population.length; i++) {
      s = splice(s, population[i].getPhrase(), s.length);
    }
    return s;
  }
}

