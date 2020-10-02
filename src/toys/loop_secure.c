#include "../../__libsym__/sym.h"

#define N 50

void init(int low, int high, int *tab) {
  for(int i = 0; i <= low && i < N; ++i) {
    tab[i] = high * i;
  }
}

int main () {

  unsigned int low, out;
  int high;
  int tab[N];

  low_input_4(&low);
  low_input_4(&out);
  low_input_200(tab);
  high_input_4(&high);
  
  init(low, high, tab);


  if (out >= N)
    out = 0;
  else {
    if(out > low && tab[out])
      out = 1;
    else
      out = 0;
  }

  return out;
}
