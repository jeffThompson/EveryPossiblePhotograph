
// TO DO:
// reverse size calculation --> screen size determines image sizes

import de.bezier.math.combinatorics.*;    // for combination-generations
import java.math.BigInteger;              // for the huge resulting numbers

/*
 GENERATE ALL COMBINATIONS, USING A SET OF 'N' IMAGES
 Jeff Thompson
 
 Uses the combinatorics library for Processing by Florian Jenett:
 https://github.com/fjenett/combinatorics
 
 www.jeffreythompson.org
 */

String items = "abcd";          // items to choose from
int step = 50;                  // time between sets in ms
int offset = 200000000;         // steps to jump ahead

int pxWide = 16;                // how many pixels wide
int pxHigh = 12;                // ditto tall

int columns = 12;               // # of combos wide to show
int rows = 9;                   // ditto high
int pad = 20;                   // padding around the image
int bottomPad = 20;             // extra bottom padding for status text
int xOffset = 10;               // a hack to get everything centered
int yOffset = 5;

int warm = 4;                   // warm up those grays a bit!

int setSize = columns * rows;   // # of combinations to generate each step
int len = pxWide * pxHigh;
String[] combinations = new String[setSize];
char l[] = items.toCharArray();                       // convert source to a char array (the easy way)
Variation variation = new Variation(l.length, len);
long prevTime = 0;
boolean next = false;
PFont font;

// how big to draw the pixels? set automatically based on the screen size
// pad + internal padding (includes a final pad on the left/bottom)
int pxSizeW = (displayWidth - pad*columns) / (pxWide*columns);
int pxSizeH = (displayHeight - pad*rows - bottomPad) / (pxHigh*rows);
// int pxSize = min(pxSizeW, pxSizeH);
int pxSize = 4;

BigInteger total = new BigInteger(str(l.length)).pow(len);       // # of combinations (from source -> BigInt)
BigInteger whichStep = new BigInteger("1");                      // keep track of which step we're at

void setup() {
  
  // size(pad + (pxWide*pxSize+pad)*columns, pad + (pxSize*pxHigh+pad)*rows + bottomPad);  // auto-set based on image details
  size(displayWidth, displayHeight);
  println("Screen resolution: " + width + " x " + height + " (" + pxSize + "px blocks)\n");
  
  smooth();
  background(0);

  font = loadFont("QuicksandBook-Regular-18.vlw");
  textFont(font, 18);
  // pxSize = max((width-(pad*2))/pxWide, (height-(pad*2))/pxHigh);

  BigInteger numToGenerate = total.divide(new BigInteger(str(setSize)));
  BigInteger timeMs = numToGenerate.multiply(new BigInteger(str(step)));
  String timeYrs = timeMs.divide(new BigInteger("31536000000")).toString();

  println("Total # of combinations:\n" + addCommas(total.toString()) + "\n\nApproximate time to finish:\n" + addCommas(timeYrs) + " years");
  
  println("\nOffsetting position by " + nfc(offset) + " (may take a while)...");
  variation.nextAndStep(offset);
  whichStep = whichStep.add(new BigInteger(Integer.toString(offset)));
}

void draw() {

  // each frame, check if it's time for a new combination
  checkTime(step);    // argument is time between in ms
  background(100+warm, 100, 100-warm);


  // if key has been pressed and there are more combos...
  if (next) {
    combinations = new String[setSize];
    for (int i=0; i<combinations.length; i++) {
      if (variation.hasMore()) {
        int[] v = variation.next();                        // get the next as an array of indices from the original
        String current = "";                               // blank string to build with
        for (int j = 0; j < v.length; j++) {               // iterate the results
          current += l[v[j]];                              // and add to the string
        }
        combinations[i] = current;                         // add to the array of results
        whichStep = whichStep.add(new BigInteger("1"));    // add as BigInts...
      }
    }
    // and reset to false
    next = false;
  }

  // create all n combinations as PGraphics
  PGraphics[] all = new PGraphics[combinations.length];
  for (int i=0; i<combinations.length; i++) {

    // more natural order: L > R, top > bottom
    // convert to a char array, reverse, convert back to a string (whew!)
    String pxData = new String(reverse(combinations[i].toCharArray()));
    all[i] = makeImage(pxData);
  }

  // draw it!
  int x = 0;
  int y = 0;
  for (int i=0; i<all.length; i++) {
    
    if (i % columns == 0 && i != 0) {
      y++;
      x = 0;
    }
    
    pushMatrix();
    translate(x*pad + x*all[i].width + pad + xOffset, y*pad + y*all[i].height + pad + yOffset);
    
    image(all[i], 0, 0);
    noFill();
    stroke(0);
    rect(-1, -1, all[i].width+1, all[i].height+1);

    // display the number of the current combination
    // fill(150+warm, 150, 150-warm);
    // textAlign(LEFT, CENTER);
    // text(addCommas(whichStep.toString()), 0, all[i].height+20);  // cast to string from BigInt, add commas

    x++;
    popMatrix();
  }
  
  // status at the bottom: the number of the current combination
  fill(150+warm, 150, 150-warm);
  textAlign(LEFT, CENTER);
  text(addCommas(whichStep.toString()), pad, height-pad);  // cast to string from BigInt, add commas


  // remove images from memory to avoid problems
  for (PGraphics p : all) {
    g.removeCache(p);
  }
}

// check if it's time for the next iteration
void checkTime(int interval) { 
  if (millis() > prevTime + interval) {
    prevTime = millis();
    next = true;
  }
}

// create an image from an array
PGraphics makeImage(String s) {

  PGraphics g = createGraphics(pxWide*pxSize, pxHigh*pxSize);

  g.beginDraw();
  g.noStroke();
  for (int y=0; y<pxHigh; y++) {
    for (int x=0; x<pxWide; x++) {

      int c = (int(s.charAt(y * pxWide + x)) - 97) * 85;

      g.fill(c+warm, c, c-warm);                           // warm up the color a bit
      g.rect(x*pxSize, y*pxSize, pxSize, pxSize);
    }
  }
  g.endDraw();

  return g;
}

// add commas to string (like nfc but for strings from BigInts, etc)
String addCommas(String s) {

  // if the number is large enough to warrant commas
  if (s.length() > 3) {
    String result = "";                     // store the result
    char[] c = s.toCharArray();             // convert the string to a char array
    c = reverse(c);                         // reverse (due to laziness but easier to understand)
    for (int i=c.length-1; i>=0; i-=1) {    // walk backwards through array
      if (i%3 == 0 && i != 0) {
        result += c[i] + ",";               // insert commas at specified location
      }
      else {
        result += c[i];                      // non-comma spots, simply add to string
      }
    }
    return result;
  }

  // if not large enough, just spit back out
  else {
    return s;
  }
}

