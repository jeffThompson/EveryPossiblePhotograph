
void loadOriginalAndOffsetImages() {
  
  // int array for offset pixels
  offsetPx = new int[pxWide * pxHigh];
  
  // load source image (here Niepce's famous photograph from 1826)
  println("\n" + "Creating starting image...");
  PImage original = loadImage("ViewFromTheWindowAtLeGras_JosephNiepce_1826.jpg");
  
  // resize (first, because otherwise resize creates new colors after
  // posterizing) and set to correct # of colors
  original.resize(pxWide, pxHigh);
  original.filter(POSTERIZE, numItems);
  
  // save the resulting image to file
  original.save("data/ViewFromTheWindowAtLeGras_JosephNiepce_1826_" + pxWide + "x" + pxHigh + "px_" + numItems + "colors.png"); 
  
  // read pixel values into offset array
  original.loadPixels();
  for (int i=0; i<original.pixels.length; i++) {
    offsetPx[i] = (original.pixels[i] >> 16 & 0xFF) / colorStep;        // get just red values, load into offset (as 1,2...N)
  }
  
  // load offset data from previous run
  try {
    PImage offsetImg = loadImage("data/Offset.png");
    println("Loading offset image...");
    offsetImg.loadPixels();
    for (int i=0; i<offsetImg.pixels.length; i++) {
      offsetPx[i] += (offsetImg.pixels[i] >> 16 & 0xFF) / colorStep;
      offsetPx[i] %= numItems;                                          // roll over 0-N
    }
  }
  catch (Exception e) {
    // skip if image doesn't exit yet
  }
}

