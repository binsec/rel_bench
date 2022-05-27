/* Source: https://github.com/imdea-software/verifying-constant-time/blob/master/examples/sort/sort.c */
#include "../../__libsym__/sym.h"
#include "lib.h"

int main() {
  int out[3];
  int in[3];

  high_input_12(&out);
  high_input_12(&in);

  sort3_multiplex(out,in);
  return 0;
}
