
void drawImage(int i, int x, int y) {
  
  // move into place
  pushMatrix();
  translate(pad + (x * imgWidth) + (x * pad) + xOffset, pad + (y * imgHeight) + (y * pad) + yOffset);

  // more natural order: L > R, top > bottom
  // convert to a char array, reverse
  char[] pxData = reverse(combinations[i].toCharArray());

  // draw pixel-by-pixel
  for (int pxY = 0; pxY < pxHigh; pxY++) {
    for (int pxX = 0; pxX < pxWide; pxX++) {

      // convert char to grayscale
      int c = int(map(int(pxData[pxY * pxWide + pxX]), 97,97+numItems-1, 0,255));
      // int c = (int(pxData[pxY * pxWide + pxX]) - 97) * 85;   // former version, doesn't quite work
      c += offsetPx[pxY * pxWide + pxX];                        // add offset
      
      // wrap color to 0-255 range, draw
      fill(c % 256);
      rect(pxX*pxSize, pxY*pxSize, pxSize, pxSize);
    }
  }
  popMatrix();
}

