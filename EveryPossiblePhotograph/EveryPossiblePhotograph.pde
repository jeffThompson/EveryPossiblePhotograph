
import de.bezier.math.combinatorics.*;    // for combination-generation
import java.math.BigInteger;              // for the huge resulting numbers :)
import java.awt.Robot;                    // for simulating mouse wiggle to hide cursor (a hack)
import java.awt.AWTException;
import java.awt.event.InputEvent;

/*
EVERY POSSIBLE PHOTOGRAPH (v4)
 Jeff Thompson | 2014 | www.jeffreythompson.org
 
 An installation attempting to generate every possible photograph
 computationally, offsetting from Niepce's first recorded 
 photographic image (ca 1826).
 
 Runs using OpenGL, because (for whatever reason) it doubles our
 frame-rate!
 
 Niepce image via:
 + http://en.wikipedia.org/wiki/File:View_from_the_Window_at_Le_Gras,_Joseph_Nic%C3%A9phore_Ni%C3%A9pce.jpg 
 
 Fullscreen on multiple projectors/monitors:
 + http://wiki.processing.org/w/Fullscreen_on_multiple_monitors
 
 REQUIRES:
 + Combinatorics library by Florian Jenett
   - https://github.com/fjenett/combinatorics
 
 */

// SETUP VARIABLES
int numItems =          4;     // colors to choose from - should not be more than 26

final int columns =     11;    // # of images across
final int rows =        8;     // ditto vertical

final int pxWide =      30;    // image size
final int pxHigh =      20;
final int pad =         40;    // space between images, in px

final int xOffset =     0;     // a hack to center the images... :(
final int yOffset =     0;
final int textYOffset = 50;    // distance from bottom for text

final int warm =         0;                   // warms up grays (0 = none, pos = warmer, neg = colder)
final int colorStep =    255/(numItems-1);    // step from 0-255 for color, based on number of items

boolean showDebug =      false;               // show framerate, etc ('d' to toggle)

final int saveInterval = 1 * (60 * 1000);                          // interval (in minutes) to save current state
String desktop =         "/Users/JeffThompson/Desktop/";           // path to desktop, for app version


// MISC VARIABLES - DO NOT CHANGE
int pxSize, imgWidth, imgHeight;                                   // image size, set after size()
Variation variation = new Variation(numItems, pxWide * pxHigh);    // # items to choose from, # of slots
int[] offsetPx = new int[pxWide * pxHigh];                         // offset image's values
int[] px = new int[pxWide * pxHigh];                               // ditto for each combination
long prevTime = 0;                                                 // stores time for auto-save
PFont font;                                                        // font for current image count
BigInteger whichStep;                                              // keep track of which step we're at
String count;
String[] countString = new String[1];                                     // array for storing previous count (only 1 item!)
BigInteger countStep = new BigInteger(Integer.toString(columns*rows));    // value to increment overall count
Robot robot;                                                              // a hack to hide the cursor


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

  // debug details
  println("# colors:      " + numItems);
  println("# images per:  " + columns + " x " + rows);
  println("Resolution:    " + pxWide + " x " + pxHigh);
  println("Pixel size:    " + pxSize + "px");
  println("Prev count:    " + addCommas(whichStep.toString()));

  // load starting and offset image
  loadOriginalAndOffsetImages();
  
  // mouse wiggle to ensure the cursor is hidden (a hack, boo)
  try {
    robot = new Robot();
    for (int i=0; i<20; i++) {
      robot.mouseMove(width/2 - 20 + i);
      delay(5);
    }
    robot.mousePress(InputEvent.BUTTON1_MASK);
    robot.mouseRelease(InputEvent.BUTTON1_MASK);
  }
  except (AWTException e) {
    // error with wiggle, skip
  }

  // ready!
  println("Ready and running!");
  println("\n- - - - - - - - - - - -\n");
}

void draw() {
  background(30+warm, 30, 30-warm);

  // draw the images!
  int x = 0;
  int y = 0;
  for (int i=0; i<columns * rows; i++) {

    if (variation.hasMore()) {
      px = variation.next();        // get next combo
      px = reverse(px);             // for some reason, variation is reverse order :(
    }

    // break to new row
    if (i % columns == 0 && i != 0) {
      y++;
      x = 0;
    }

    drawImage(x, y, px);
    x++;
  }

  // display current count
  count = addCommas(whichStep.toString());              // convert to string, add commas
  count = count.substring(0, count.length()-1) + "0";   // hack to get the count to be a little prettier onscreen
  fill(255);
  text(count, pad + xOffset, height - textYOffset);
  whichStep = whichStep.add(countStep);                 // increment count (probably a little faster than each image)

  // display frame rate (for debugging and testing)
  if (showDebug) {
    textAlign(CENTER); 
    text(frameRate + " fps", width/2 - xOffset/2, height - textYOffset);
    textAlign(LEFT);
    // if (frameRate < 25) println("dropped frames");
  }

  // save periodically
  if (millis() > prevTime + saveInterval) {
    saveState();
    prevTime = millis();
  }
}

