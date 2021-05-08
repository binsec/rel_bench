#include "../../../__libsym__/sym.h"

int main () {

  int obs;
  int high;
  
  low_input_4(&obs);
  high_input_4(&high);

  if (obs == 16) {
    obs = 0;
  } else {
    obs = 1;
  }
  
  return 0;
}
