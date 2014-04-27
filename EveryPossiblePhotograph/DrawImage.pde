
void drawImage(int x, int y, int[] px) {
  
  // move into place
  pushMatrix();
  translate(pad + (x * imgWidth) + (x * pad) + xOffset, pad + (y * imgHeight) + (y * pad) + yOffset);

  // draw pixel-by-pixel
  for (int pxY = 0; pxY < pxHigh; pxY++) {
    for (int pxX = 0; pxX < pxWide; pxX++) {

      // add offset, put into 0-N range, then into 0-255
      int c = px[pxY * pxWide + pxX] + offsetPx[pxY * pxWide + pxX];
      c = (c % numItems) * colorStep;
      
      // draw pixel
      fill(c+warm, c, c-warm);
      rect(pxX*pxSize, pxY*pxSize, pxSize, pxSize);
    }
  }
  
  popMatrix();
}

