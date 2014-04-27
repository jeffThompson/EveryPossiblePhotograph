
class DNA {

  // The genetic sequence
  char[] genes;

  double fitness;

  // Constructor (makes DNA)
  DNA(int num) {
    genes = new char[num];
    for (int i = 0; i < genes.length; i++) {
      int temp = int(random(0, 5));
      // print (temp + "  ");
      genes[i] = char(temp + 97);
    }
    // print("\n");
  }

  // Converts character array to a String
  String getPhrase() {
    return new String(genes);
  }

  // Fitness function (returns floating point % of "correct" characters)
  void fitness (String target) {
    int score = 0;
    for (int i = 0; i < genes.length; i++) {
      if (genes[i] == target.charAt(i)) {
        score++;
      }
    }
    fitness = pow(2, score);                             // original fitness score
    // fitness = float(score)/float(target.length());    // percentage (incl in original example)
    // fitness = score;                                  // handles longer texts, but is MUCH slower
  }

  // Crossover
  DNA crossover(DNA partner) {
    // A new child
    DNA child = new DNA(genes.length);

    int midpoint = int(random(genes.length)); // Pick a midpoint

    // Half from one, half from the other
    for (int i = 0; i < genes.length; i++) {
      if (i > midpoint) {
        child.genes[i] = genes[i];
      }
      else {
        child.genes[i] = partner.genes[i];
      }
    }
    return child;
  }

  // Based on a mutation probability, picks a new random character
  void mutate(float mutationRate) {
    for (int i = 0; i < genes.length; i++) {
      if (random(1) < mutationRate) {
        genes[i] = (char)random(97, 101);
      }
    }
  }
}

