#include "../../../__libsym__/sym.h"

int foo (int low, int high) {
  
  low = high - 10;

  return low;
}

int main () {

  int low;
  int high;

  low_input_4(&low);
  high_input_4(&high);
  
  high = high * 10;

  low = foo(low, high);

  if (low == 31) { // Feasible with high = 4;
    low = 0;
  } else {
    low = 1;
  }
  
  return 0;
}
