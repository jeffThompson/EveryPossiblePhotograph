/*
GENETIC INTERPOLATION
 Jeff Thompson
 
 A FEW NOTES:
 + larger population = fewer steps
 + larger mutation rate gets closer to purely random "stabs in the dark", which might
 mean more steps, will definitely mean a wavier path to the result, but might
 also mean quick results
 
 NOTE: changed 'perfectscore' and 'worldrecord' in Population.pde to doubles for longer strings
 
 Based heavily on code by Daniel Shiffman: http://www.shiffman.net (thanks!)
 
 www.jeffreythompson.org
 */

// 2-bit/4-color grayscale: a=0, b=85, c=170, d=255
String target = "ccbdccdcdbcbcbabbcbabaabbbabaabcbabaaaabbc";    // what we're trying for
int pxWide = 7;                                // # pixels wide
int pxHigh = 6;                                // ditto high
int pxSize = 10;                               // how large to draw them
int pad = 100;                                 // padding around the sides
int warm = 5;                                  // warm up the grays a bit!

int popSize = 10;             // how many agents to swarm through the text
float mutationRate = 0.001;   // percent mutation rate
int fontSize = 32;            // size for the text
boolean saveIt = false;       // save a still image when done?

PFont f;
Population population;
String start;
PGraphics startImage;
int numPx = pxWide*pxHigh;
int space = 30;

void setup() {

  f = loadFont("QuicksandBook-Regular-32.vlw");    // note: textWidth does not seem to work with createFont...
  textFont(f, 14);
  textAlign(CENTER, CENTER);
  smooth();
  noStroke();

  // size(pxWide*pxSize + pad*2, (pxHigh*pxSize)*2 + pad*3);
  size(pad*2 + (pxWide*pxSize+space)*popSize, pad + (pxSize*pxHigh) + pad + (50*pxHigh) + pad);

  // Create a population with a target phrase, mutation rate, and population size
  population = new Population(target, mutationRate, popSize);
}

void draw() {

  background(90+warm, 90, 90-warm);

  population.naturalSelection();
  population.generate();
  population.calcFitness();

  // show all members of the population
  String[] everyone = population.allPhrases();
  for (int i=0; i<everyone.length; i++) {
    PGraphics all = makeImage(everyone[i], pxSize);
    image(all, i*all.width+space*i+pad, pad);
    noFill();
    stroke(0);
    rect(i*all.width+space*i+pad, pad, all.width, all.height);
  }

  // best result
  String answer = population.getBest();
  PGraphics g = makeImage(answer, 50);
  image(g, width/2-g.width/2, height-g.height-pad);
  noFill();
  stroke(0);
  rect(width/2-g.width/2, height-g.height-pad, g.width, g.height);    // border

  // If we found the target phrase, stop
  if (population.finished()) {

    // how long did it take?
    fill(180);
    textAlign(LEFT);
    text(millis()/1000.0 + " seconds", 20, height-20);
    textAlign(RIGHT);
    text(frameCount + " steps", width-20, height-20);
    println(frameCount + " steps / " + millis()/1000.0 + " seconds");

    if (saveIt) {
      save("GeneticInterpolation_Sonnet-large.png");
    }
    noLoop();
  }
  else {
    fill(180);
    textAlign(RIGHT);
    text(frameCount + " steps", width-20, height-20);
    textAlign(LEFT);
    text("Working...", 20, height-20);
  }
}

PGraphics makeImage(String s, int pSize) {

  PGraphics g = createGraphics(pxWide*pSize, pxHigh*pSize, P2D);

  g.beginDraw();
  g.noStroke();
  for (int y=0; y<pxHigh; y++) {
    for (int x=0; x<pxWide; x++) {

      int c = (int(s.charAt(y * pxWide + x)) - 97) * 85;

      g.fill(c+warm, c, c-warm);                           // warm up the color a bit
      g.rect(x*pSize, y*pSize, pSize, pSize);
    }
  }
  g.endDraw();

  return g;
}

