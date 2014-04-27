
import de.bezier.math.combinatorics.*;    // for combination-generations
import java.math.BigInteger;              // for the huge resulting numbers
import processing.opengl.*;               // optimize by running on the GPU

/*
 EVERY POSSIBLE PHOTOGRAPH (v4, OpenGL + offset)
 Jeff Thompson | 2012-14 | www.jeffreythompson.org
 
 Built on the OpenGL renderer to speed things up (a lot).
 
 Offsets from Niepce's first recorded photograph, ca 1826, via:
 + http://en.wikipedia.org/wiki/File:View_from_the_Window_at_Le_Gras,_Joseph_Nic%C3%A9phore_Ni%C3%A9pce.jpg
 
 REQUIRES:
 + Combinatorics library by Florian Jenett:
   - https://github.com/fjenett/combinatorics
 
 TO DO: 
 + save state
 + restore state
 + figure out which combination source image is
 
 */

final String items = "abcd";          // items to choose from
final int step = 100;                 // time between sets in ms

final int pxWide = 15;                // how many pixels wide
final int pxHigh = 10;                // ditto tall

final int columns = 14;               // # of combos wide to show
final int rows = 10;                  // ditto high
final int pad = 20;                   // padding around the image
final int bottomPad = 20;             // extra bottom padding for status text
final int xOffset =  7;               // a hack to get everything centered
final int yOffset = 5;

final int warm = 4;                   // warm up those grays a bit!

final boolean saveIt = false;         // save each frame?

final int setSize = columns * rows;                   // # of combinations to generate each step
final int len = pxWide * pxHigh;                      // combo length
String[] combinations = new String[setSize];
char l[] = items.toCharArray();                       // convert source to a char array (the easy way)
long prevTime = 0;                                    // for keeping track of when to update
boolean next = false;                                 // ditto, triggers redraw
PFont font;
Variation variation = new Variation(l.length, len);   // for the actual combinations
PImage sourceImg;
int[] offsetPx = new int[pxWide * pxHigh];

// how big to draw the pixels? set automatically based on the screen size
// pad + internal padding (includes a final pad on the left/bottom)
final int pxSizeW = (displayWidth - pad*columns) / (pxWide*columns);
final int pxSizeH = (displayHeight - pad*rows - bottomPad) / (pxHigh*rows);
// final int pxSize = min(pxSizeW, pxSizeH);
int pxSize = 4;

final int imgWidth = pxWide * pxSize;
final int imgHeight = pxHigh * pxSize;

BigInteger total = new BigInteger(str(l.length)).pow(len);       // # of combinations (from source -> BigInt)
BigInteger whichStep = new BigInteger("1");                      // keep track of which step we're at

void setup() {

  // auto-set size based on image details
  size(pad + (pxWide*pxSize+pad)*columns + pad, pad + (pxSize*pxHigh+pad)*rows + bottomPad, OPENGL);
  // size(displayWidth, displayHeight, OPENGL);
  println("Screen resolution: " + width + " x " + height + " (" + pxSize + "px blocks)\n");

  // load offset image pixels, store to array
  sourceImg = loadImage("ViewFromTheWindowAtLeGras_JosephNiepce_1826_15x10px.png");
  sourceImg.loadPixels();
  for (int i=0; i<sourceImg.pixels.length; i++) {
    offsetPx[i] = sourceImg.pixels[i] >> 16 & 0xFF;
  }

  smooth();
  noStroke();
  noCursor();
  prepareExitHandler();        // to save state on exit
  frame.setTitle("Every Possible Photograph | Jeff Thompson");

  // load font
  font = loadFont("QuicksandBook-Regular-18.vlw");
  textFont(font, 18);
  // pxSize = max((width-(pad*2))/pxWide, (height-(pad*2))/pxHigh);

  // create combination count
  BigInteger numToGenerate = total.divide(new BigInteger(str(setSize)));
  BigInteger timeMs = numToGenerate.multiply(new BigInteger(str(step)));
  String timeYrs = timeMs.divide(new BigInteger("31536000000")).toString();
  println("Total # of combinations:\n" + addCommas(total.toString()) + "\n\nApproximate time to finish:\n" + addCommas(timeYrs) + " years");

  // skip ahead in the list of combinations
  // println("\nOffsetting position by " + nfc(offset) + " (may take a while)...");
  // variation.nextAndStep(offset);
  // whichStep = whichStep.add(new BigInteger(Integer.toString(offset)));
}

void draw() {

  // run in a try/catch to check if we've run out of combinations
  // note: this will NEVER happen, except when testing :)
  try {

    // each frame, check if it's time for a new combination
    checkTime(step);                      // argument is time between in ms
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
      next = false;      // and reset to false
    }

    // create all N combinations as PGraphics
    int x = 0;
    int y = 0;
    for (int i=0; i<combinations.length; i++) {

      if (i % columns == 0 && i != 0) {
        y++;
        x = 0;
      }

      pushMatrix();
      translate(x*pad + x*imgWidth + pad + xOffset, y*pad + y*imgHeight + pad + yOffset);

      // more natural order: L > R, top > bottom
      // convert to a char array, reverse
      char[] pxData = reverse(combinations[i].toCharArray());

      for (int pxY=0; pxY<pxHigh; pxY++) {
        for (int pxX=0; pxX<pxWide; pxX++) {

          int c = (int(pxData[pxY * pxWide + pxX]) - 97) * 85;   // convert char to grayscale
          c += offsetPx[pxY * pxWide + pxX];                     // add offset
          c %= 255;                                              // wrap to 0-255 range

          fill(c+warm, c, c-warm);                               // warm up the color a bit
          noStroke();
          rect(pxX*pxSize, pxY*pxSize, pxSize, pxSize);
        }
      }     

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
    text(addCommas(whichStep.toString()), pad+xOffset, height-pad);  // cast to string from BigInt, add commas

    // save state each frame
    saveState();
  }

  // ends the program when we run out of combinations...
  catch (NullPointerException e) {
    println("\nDONE!");
    exit();
  }

  // save frames for documentation
  if (saveIt) {
    saveFrame("stills/#####_EveryPossiblePhotograph.png");
  }
}

// check if it's time for the next iteration
void checkTime(int interval) { 
  if (millis() > prevTime + interval) {
    prevTime = millis();
    next = true;
  }
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

void saveState() {
  //println("Saving current state...");

  char[] c = combinations[combinations.length-1].toCharArray();
  c = reverse(c);

  PImage exitState = createImage(pxWide, pxHigh, RGB);
  exitState.loadPixels();
  for (int i=0; i<exitState.pixels.length; i++) {
    exitState.pixels[i] = color((c[i] - 97) * 85);    // convert char to grayscale
  }
  exitState.updatePixels();
  exitState.save("Offset_15x10.png");
}

// save state on exit
// via: https://forum.processing.org/topic/run-code-on-exit
void prepareExitHandler () {
  Runtime.getRuntime().addShutdownHook(new Thread(new Runnable() {
    public void run() {
      try {


        // ...and quit!      
        stop();
      } 
      catch (Exception ex) {
        ex.printStackTrace();     // not much else to do at this point...
      }
    }
  }
  ));
}

