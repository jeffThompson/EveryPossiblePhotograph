
void comboSetup() {
  
  // if too many choices, auto-reduce
  if (numItems > 26) {
    numItems = 26;
    println("[ too many items requested, reducing to 26 ]");
  }
  
  // create array of chars
  print("Items:         ");
  for (int i=0; i<numItems; i++) {
    items[i] = char(97 + i);           // start at 'a'
    print(char(97 + i));
    if (i < numItems-1) print(", ");
  }
  println();
  
}

