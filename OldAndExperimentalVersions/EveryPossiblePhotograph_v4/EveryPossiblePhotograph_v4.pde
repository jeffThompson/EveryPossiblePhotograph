
import de.bezier.math.combinatorics.*;    // for combination-generations
import java.math.BigInteger;              // for the huge resulting numbers :)

/*
EVERY POSSIBLE PHOTOGRAPH (v4)
Jeff Thompson | 2014 | www.jeffreythompson.org

An installation attempting to generate every possible photograph
computationally, offsetting from Niepce's first recorded 
photographic image (ca 1826).

Runs using OpenGL, as (for whatever reason) it doubles our
frame-rate!
 
Niepce image via:
+ http://en.wikipedia.org/wiki/File:View_from_the_Window_at_Le_Gras,_Joseph_Nic%C3%A9phore_Ni%C3%A9pce.jpg 

Fullscreen on multiple projectors/monitors:
+ http://wiki.processing.org/w/Fullscreen_on_multiple_monitors

REQUIRES:
+ Combinatorics library by Florian Jenett
  - https://github.com/fjenett/combinatorics

TO DO:
+ why doesn't combo show black px?
+ better spacing (% of width?)

*/

// SETUP VARIABLES
int numItems = 4;              // colors to choose from - should not be more than 26

final int columns = 10;        // # of images across
final int rows = 8;            // ditto vertical

final int pxWide = 30;         // image size
final int pxHigh = 20;
final int pad = 40;            // space between images, in px

final int xOffset = pad;       // a hack to center the images... :(
final int yOffset = 0;
final int textYOffset = 50;    // distance from bottom for text

final int warm = 0;            // warms up grays (0 = none, pos = warmer, neg = colder)

final int saveInterval = 1 * (60 * 1000);     // interval (in minutes) to save current state

boolean showFrameRate = false;                // show framerate ('r' to toggle)

// MISC VARIABLES - DO NOT CHANGE
int pxSize, imgWidth, imgHeight;                                 // image size, set after size()
char[] items = new char[numItems];                               // array of items to choose from
Variation variation = new Variation(numItems, pxWide * pxHigh);  // # items to choose from, # of slots
String[] combinations = new String[columns * rows];              // resulting an array of images
BigInteger whichStep;                                            // keep track of which step we're at
String count;
String[] countString = new String[1];                            // array for storing previous count (only 1 item!)
PFont font;                                                      // font for current image count
int[] offsetPx;                                                  // offset image's values
long prevTime = 0;                                               // stores time for auto-save


void setup() {

  // basic setup
  size(displayWidth, displayHeight, OPENGL);      // just usig OPENGL doubles the frame-rate!
  noStroke();
  noCursor();
  frame.setTitle("Every Possible Photograph");
  font = loadFont("Consolas-18.vlw");             // monospaced font is better
  textFont(font, 18);

  // image size - must happen after size() is set
  int pxSizeW = (width - pad*columns) / (pxWide*columns);
  int pxSizeH = (height - pad*rows) / (pxHigh*rows);
  pxSize = min(pxSizeW, pxSizeH);
  imgWidth = pxWide * pxSize;
  imgHeight = pxHigh * pxSize;
  
  // load previous count
  countString = loadStrings("data/count.txt");     // load from file
  whichStep = new BigInteger(countString[0]);      // set to BigInt for adding, set string version in draw()

  // create combination choices
  comboSetup();

  // debug details
  println("# colors:      " + numItems);
  println("# images per:  " + columns + " x " + rows);
  println("Resolution:    " + pxWide + " x " + pxHigh);
  println("Pixel size:    " + pxSize + "px");
  println("Prev count:    " + addCommas(whichStep.toString()));
  
  // load starting and offset image
  loadOriginalAndOffsetImages();
  
  // ready!
  println("Ready and running!");
  println("\n- - - - - - - - - - - -\n");  
}

void draw() {
  background(30+warm, 30, 30-warm);

  // get list of combinations
  combinations = getCombinations();

  // draw the images!
  int x = 0;
  int y = 0;
  for (int i=0; i<combinations.length; i++) {

    // break to new row
    if (i % columns == 0 && i != 0) {
      y++;
      x = 0;
    }

    drawImage(i, x, y);
    x++;
  }

  // display current count
  count = addCommas(whichStep.toString());              // convert to string, add commas
  count = count.substring(0, count.length()-1) + "0";   // hack to get the count to be a little prettier onscreen
  fill(255);
  text(count, pad + xOffset, height - textYOffset);
  
  // display frame rate (for debugging and testing)
  if (showFrameRate) {
    textAlign(RIGHT);
    text(frameRate, width-pad-xOffset, height - textYOffset);
    textAlign(LEFT);
  }
  
  // save periodically
  if (millis() > prevTime + saveInterval) {
    saveState();
    prevTime = millis();
  }
}

