#include "../../../__libsym__/sym.h"

int main () {

  int obs;
  int high;
  int tab[3] = {1,2,3};

  low_input_4(&obs);
  low_input_12(tab);
  high_input_4(&high);

  
  high = high * high;
  obs = high;
  obs = obs & 0x03;
  
  high = tab[obs];
  
  return 0;
}
