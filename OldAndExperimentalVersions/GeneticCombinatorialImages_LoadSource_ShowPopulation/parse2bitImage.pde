
// returns a string representation of a 2-bit image
// 2-bit/4-color grayscale: a=0, b=85, c=170, d=255

String parse2bitImage(PImage img) {

  // rotate to fit specifications
  if (pxWide > pxHigh && img.width < img.height) {        // if supposed to be horiz and isn't
  }
  else if (pxWide < pxHigh && img.width > img.height) {   // if supposed to be vert and isn't
  }

  // resize
  img.resize(pxWide, pxHigh);

  // read pixels, convert to 2-bit
  String s = "";
  img.loadPixels();
  for (int i=0; i<img.pixels.length; i++) {
    int px = int(red(img.pixels[i]));
    if (px >= 0 && px < 64) {
      s += "d";
    }
    else if (px >= 128 && px < 192) {
      s += "c";
    }
    else if (px >= 192 && px < 255) {
      s += "d";
    }
    else {
      s += "a";
    }
  }

  return s;
}
