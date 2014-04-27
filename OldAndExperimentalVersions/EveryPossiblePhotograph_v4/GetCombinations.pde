
String[] getCombinations() {
  
  // no need to clear the array, since we overwrite every item
  // (and clearing to a new variable takes memory)
  
  for (int i=0; i<combinations.length; i++) {
    if (variation.hasMore()) {
      int[] v = variation.next();                        // get the next as an array of indices from the original
      String current = "";                               // blank string to build with
      for (int j = 0; j < v.length; j++) {               // iterate the results
        current += items[v[j]];                          // and add to the string
      }
      combinations[i] = current;                         // add to the array of results
      
      // update step count (add as BigInts)
      whichStep = whichStep.add(new BigInteger("1"));
    }
  }
  
  // return new array of combinations
  return combinations;
}

