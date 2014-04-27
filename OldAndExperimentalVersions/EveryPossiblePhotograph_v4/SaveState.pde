
// save state of the program as an image file
void saveState() {
  println(nf(hour(),2) + ":" + nf(minute(),2) + " - saving current state...");

  // grab final image onscreen
  char[] c = combinations[combinations.length-1].toCharArray();
  c = reverse(c);

  // create PImage, load in pixels from combination
  PImage exitState = createImage(pxWide, pxHigh, RGB);
  exitState.loadPixels();
  for (int i=0; i<exitState.pixels.length; i++) {
    exitState.pixels[i] = color((c[i] - 97) * 85);    // convert char to grayscale
  }
  exitState.updatePixels();
  
  // save for reload... 
  exitState.save("data/Offset.png");
  
  // ...and version with datetime for documentation (since reload version gets overwritten)
  // naming format: Offset_year-month-day_hour-minute-second.png
  exitState.save("documentation/offset/Offset_" + year() + "-" + nf(month(),2) + "-" + nf(day(),2) + "_" + nf(hour(),2) + "-" + nf(minute(),2) + "-" + nf(second(),2) + ".png");
  
  // ...and the full screen (so we can record the finished combinations)
  save("documentation/screen/Screen_" + year() + "-" + nf(month(),2) + "-" + nf(day(),2) + "_" + nf(hour(),2) + "-" + nf(minute(),2) + "-" + nf(second(),2) + ".png");
  
  // finally, save current count
  // we don't use the prettified string count because it would cause issues when loading
  countString[0] = whichStep.toString();
  saveStrings("data/count.txt", countString);
}

