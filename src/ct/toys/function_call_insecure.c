#include "../../../__libsym__/sym.h"

int foo (int low, int high) {
  
  low = high - 10;
  
  if (low == 30) { // Feasible with high = 4;
    low = 0;
  } else {
    low = 1;
  }

  return low;
}

int main () {

  int low;
  int high;

  low_input_4(&low);
  high_input_4(&high);
  
  high = high * 10;

  foo(low, high);
  
  return 0;
}
