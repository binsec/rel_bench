#include "../../../__libsym__/sym.h"

int main () {

  int obs;
  int high;

  low_input_4(&obs);
  high_input_4(&high);
  
  high = high * high;
  obs = high;

  if (obs == 16) {// Feasible with high = 4;
    obs = 0;
  } else {
    obs = 1;
  }
  
  return 0;
}
