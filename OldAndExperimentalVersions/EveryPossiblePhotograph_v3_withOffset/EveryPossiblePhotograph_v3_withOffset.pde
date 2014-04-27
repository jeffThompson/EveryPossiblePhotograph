
int numChoices = 256;
int numItems = 3;

Integer[] choices = new Integer[numChoices];
PImage source;
Integer[] offset;
Generator<Integer> gen;

void setup() {

//  source = loadImage(sourceImageFilename);
//  size(source.width, source.height);
//
//  source.filter(GRAY);
//  source.loadPixels();
//  offset = new Integer[source.pixels.length];
//  for (int i=0; i<source.pixels.length; i++) {
//    offset[i] = source.pixels[i] >> 16 & 0xFF;
//  }

  for (int i=0; i<numChoices; i++) {
    choices[i] = i;
  }

  //http://code.google.com/p/combinatoricslib/#4._Combinations_with_repetitions
  ICombinatoricsVector<Integer> initialVector = Factory.createVector(choices);
  gen = Factory.createMultiCombinationGenerator(initialVector, numItems);
}

void draw() {
  //loadPixels();
  //
  //updatePixels();
}

void keyPressed() {
  if (key == 32 && gen.hasNext()) {
    println(" next..");
  }
}

