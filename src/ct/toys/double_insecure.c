#include "../../../__libsym__/sym.h"

int main () {

  int tab[10];
  int high;
  int obs;

  low_input_40(tab);
  low_input_4(&obs);
  high_input_4(&high);
  
  high = high % 9;
  
  if (obs > 0) {
    obs = tab[high];
  } else {
    obs = tab[high+1];
  }
  return obs;
}
