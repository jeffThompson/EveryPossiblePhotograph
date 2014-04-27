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

String targetImage = "test.png";    // image file to load as target

int pxWide = 16;                    // # pixels wide
int pxHigh = 9;                     // ditto high
int pxSize = 5;                     // how large to draw them
int pad = 100;                      // padding around the sides
int warm = 5;                       // warm up the grays a bit!
int mainPxSize = 25;                 // pixel size for the main image

int popSize = 10;                   // how many agents to swarm through the text
float mutationRate = 0.001;         // percent mutation rate
int fontSize = 32;                  // size for the text
boolean saveIt = false;             // save a still image when done?

PFont f;
Population population;
String target;
String start;
PImage tImg;
PGraphics targetImg;
int numPx = pxWide*pxHigh;
int space = 30;

void setup() {

  // load the source image, convert to a string of 2-bit values
  tImg = loadImage(targetImage);
  target = parse2bitImage(tImg);
  targetImg = makeImage(target, mainPxSize);

  f = loadFont("QuicksandBook-Regular-32.vlw");    // note: textWidth does not seem to work with createFont...
  textFont(f, 14);
  textAlign(CENTER, CENTER);
  smooth();
  noStroke();

  // whichever is larger - the population or two main images
  int w = max(pad*2 + (pxWide*pxSize+space)*popSize-space, (mainPxSize*pxWide)*2 + pad*2);
  size(w, pad + (pxSize*pxHigh) + pad + (mainPxSize*pxHigh) + pad);

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

  // target image (for debugging)
  image(targetImg, width-pad-targetImg.width, height-targetImg.height-pad);
  noFill();
  stroke(0);
  rect(width-pad-targetImg.width, height-pad-targetImg.height, targetImg.width, targetImg.height);
  fill(180);
  textAlign(RIGHT);
  text("TARGET", width-pad, height-pad-targetImg.height-10);

  // best result
  String answer = population.getBest();
  PGraphics g = makeImage(answer, mainPxSize);
  image(g, pad, height-g.height-pad);
  noFill();
  stroke(0);
  rect(pad, height-g.height-pad, g.width, g.height);    // border

  // If we found the target phrase, stop
  if (population.finished()) {

    // how long did it take?
    fill(180);
    textAlign(LEFT);
    text(millis()/1000.0 + " seconds", 20, height-20);
    textAlign(RIGHT);
    text(nfc(frameCount) + " steps", width-20, height-20);
    println(nfc(frameCount) + " steps / " + millis()/1000.0 + " seconds");

    textAlign(LEFT);
    text("DONE!", pad, height-pad-g.height-10);

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
    text("IN PROGRESS...", pad, height-pad-g.height-10);
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

