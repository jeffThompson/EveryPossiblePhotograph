
int numItems = 4;
char px = 'a';
int offset = 150;

println("px" + "\t" + "orig" + "\t" + "offset" + "\t" + "result");

for (int i=0; i<numItems; i++) {
  print(char(px + i));
  
  int c = px + offset + i;
  print("\t" + c);
  
  c %= 97;
  println("\t" + c);
  
//  int c = int(map(int(px + i), 97, 97+numItems-1, 0, 255));
//  print("\t" + c);
//
//  c += offset;
//  print("\t" + c);
//  
//  c %= 256;
//  println("\t" + c);
}

exit();

